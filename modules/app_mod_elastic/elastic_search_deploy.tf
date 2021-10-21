/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// CRD: https://download.elastic.co/downloads/eck/1.8.0/crds.yaml
// Operator: https://download.elastic.co/downloads/eck/1.8.0/operator.yaml

locals {
  k8s_credentials_cmd    = "gcloud container clusters get-credentials ${module.gke_cluster.name} --region ${var.region} --project ${module.elastic_search_project.project_id}"
  elastic_namespace_name = "elastic-search"
}

provider "kubernetes" {
  cluster_ca_certificate = module.gke_authentication.cluster_ca_certificate
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = module.gke_authentication.token

  experiments {
    manifest_resource = true
  }
}

resource "null_resource" "update_local_context" {

  provisioner "local-exec" {
    command = local.k8s_credentials_cmd
  }
}

module "deploy_eck_crds" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
  version = "~> 3.0.0"

  project_id              = module.elastic_search_project.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl create -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  kubectl_destroy_command = "kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  skip_download           = true
  use_existing_context    = true
  upgrade                 = false

  module_depends_on = [
    module.elastic_search_project.project_id,
    module.gke_cluster.endpoint,
    null_resource.update_local_context.id
  ]
}

module "deploy_eck_operator" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
  version = "~> 3.0"

  project_id              = module.elastic_search_project.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  kubectl_destroy_command = "kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  skip_download           = true
  use_existing_context    = true
  upgrade                 = false

  module_depends_on = [
    module.elastic_search_project.project_id,
    module.gke_cluster.endpoint,
    module.deploy_eck_crds.wait
  ]
}

resource "kubernetes_namespace" "elastic_search_namespace" {
  metadata {
    annotations = {
      name = local.elastic_namespace_name
    }

    labels = {
      workload = "elastic-search"
    }

    name = "elastic-search"
  }

  depends_on = [
    module.deploy_eck_crds,
    module.deploy_eck_operator
  ]
}

resource "kubernetes_manifest" "elastic_search" {
  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind"       = "Elasticsearch"

    metadata = {
      name      = "es-quickstart"
      namespace = local.elastic_namespace_name
    }

    spec = {
      version = "7.15.1"
      nodeSets = [{
        name  = "default"
        count = "1"
        config = {
          "node.store.allow_mmap" = "false"
        }
      }]
    }
  }

  depends_on = [
    module.deploy_eck_crds,
    module.deploy_eck_operator,
    kubernetes_namespace.elastic_search_namespace
  ]
}

resource "kubernetes_manifest" "kibana" {
  manifest = {
    "apiVersion" = "kibana.k8s.elastic.co/v1"
    "kind" : "Kibana"

    metadata = {
      name      = "es-quickstart"
      namespace = local.elastic_namespace_name
    }

    spec = {
      version = "7.15.1"
      count   = "1"
      elasticsearchRef = {
        "name" = "es-quickstart"
      }
    }
  }
}
