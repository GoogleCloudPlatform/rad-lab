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

locals {
  k8s_credentials_cmd          = "gcloud container clusters get-credentials ${module.gke_cluster.name} --region ${var.region} --project ${local.project_id}"
  elastic_namespace_name       = "elastic-search"
  elastic_search_identity_name = "es-identity"
}

provider "kubernetes" {
  cluster_ca_certificate = module.gke_authentication.cluster_ca_certificate
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = module.gke_authentication.token
}

module "deploy_eck_crds" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
  version = "~> 3.0.0"

  project_id              = local.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl create -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  kubectl_destroy_command = "kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  skip_download           = true
  upgrade                 = false

  module_depends_on = [
    module.gke_cluster.endpoint,
  ]
}

module "deploy_eck_operator" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
  version = "~> 3.0"

  project_id              = local.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  kubectl_destroy_command = "kubectl get namespaces --no-headers -o custom-columns=:metadata.name | xargs -n1 kubectl delete elastic --all -n && kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  skip_download           = true
  upgrade                 = false

  module_depends_on = [
    module.gke_cluster.endpoint, # Force dependency between modules
    module.deploy_eck_crds.wait,
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
    module.deploy_eck_operator,
    module.gke_cluster
  ]
}

resource "kubernetes_service_account" "elastic_search_identity" {
  metadata {
    name      = local.elastic_search_identity_name
    namespace = local.elastic_namespace_name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.elastic_search_gcp_identity.name}@${local.project_id}.iam.gserviceaccount.com"
    }
  }

  depends_on = [
    module.elastic_search_project,
    module.gke_cluster.node_pools_names,
    kubernetes_namespace.elastic_search_namespace
  ]
}

data "template_file" "elastic_search_yaml" {
  template = file("${path.module}/templates/elastic_search_deployment.yaml.tpl")
  vars = {
    NAMESPACE            = local.elastic_namespace_name
    COUNT                = var.elastic_search_instance_count
    VERSION              = var.elk_version
    SERVICE_ACCOUNT_NAME = local.elastic_search_identity_name
  }
}

data "template_file" "kibana_yaml" {
  template = file("${path.module}/templates/kibana_deployment.yaml.tpl")
  vars = {
    NAMESPACE            = local.elastic_namespace_name
    COUNT                = var.kibana_instance_count
    VERSION              = var.elk_version
    SERVICE_ACCOUNT_NAME = local.elastic_search_identity_name
  }
}

resource "local_file" "elastic_search_yaml_output" {
  filename = "${path.module}/elk/elastic_search_deployment.yaml"
  content  = data.template_file.elastic_search_yaml.rendered
}

resource "local_file" "kibana_yaml_output" {
  filename = "${path.module}/elk/kibana_deployment.yaml"
  content  = data.template_file.kibana_yaml.rendered
}

module "deploy_elastic_search" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"
  version = "~> 3.0"

  project_id              = local.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl apply -f ${path.module}/elk"
  kubectl_destroy_command = "kubectl delete -f ${path.module}/elk"
  skip_download           = true
  upgrade                 = false

  module_depends_on = [
    module.gke_cluster.endpoint,
    module.deploy_eck_crds.wait,
    module.deploy_eck_operator.wait,
    local_file.elastic_search_yaml_output.filename,
    local_file.kibana_yaml_output.filename,
    kubernetes_namespace.elastic_search_namespace.id,
    kubernetes_service_account.elastic_search_identity.id
  ]
}
