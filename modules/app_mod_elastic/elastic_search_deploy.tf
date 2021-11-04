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
  k8s_credentials_cmd          = "gcloud container clusters get-credentials ${module.gke_cluster.name} --region ${var.region} --project ${local.project.project_id}"
  elastic_namespace_name       = "elastic-search"
  elastic_search_identity_name = "es-identity"
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
}

module "deploy_eck_crds" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id              = local.project.project_id
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

  project_id              = local.project.project_id
  cluster_name            = module.gke_cluster.name
  cluster_location        = var.region
  kubectl_create_command  = "kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  kubectl_destroy_command = "${path.module}/scripts/remove_eck_operator.sh && kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  skip_download           = true
  upgrade                 = false

  module_depends_on = [
    module.gke_cluster.endpoint, # Force dependency between modules
    module.deploy_eck_crds.wait,
  ]
}

resource "kubernetes_namespace" "elastic_search_namespace" {
  count = var.deploy_elastic_search ? 1 : 0

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
  count = var.deploy_elastic_search ? 1 : 0

  metadata {
    name      = local.elastic_search_identity_name
    namespace = local.elastic_namespace_name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.elastic_search_gcp_identity.name}@${local.project.project_id}.iam.gserviceaccount.com"
    }
  }

  depends_on = [
    module.gke_cluster.node_pools_names,
    kubernetes_namespace.elastic_search_namespace
  ]
}

data "template_file" "elastic_search_yaml" {
  count    = var.deploy_elastic_search ? 1 : 0
  template = file("${path.module}/templates/elastic_search_deployment.yaml.tpl")
  vars = {
    NAMESPACE            = local.elastic_namespace_name
    COUNT                = var.elastic_search_instance_count
    VERSION              = var.elk_version
    SERVICE_ACCOUNT_NAME = local.elastic_search_identity_name
  }
}

data "template_file" "kibana_yaml" {
  count    = var.deploy_elastic_search ? 1 : 0
  template = file("${path.module}/templates/kibana_deployment.yaml.tpl")
  vars = {
    NAMESPACE            = local.elastic_namespace_name
    COUNT                = var.kibana_instance_count
    VERSION              = var.elk_version
    SERVICE_ACCOUNT_NAME = local.elastic_search_identity_name
  }
}

resource "local_file" "elastic_search_yaml_output" {
  count    = var.deploy_elastic_search ? 1 : 0
  filename = "${path.module}/elk/elastic_search_deployment.yaml"
  content  = data.template_file.elastic_search_yaml.0.rendered
}

resource "local_file" "kibana_yaml_output" {
  count    = var.deploy_elastic_search ? 1 : 0
  filename = "${path.module}/elk/kibana_deployment.yaml"
  content  = data.template_file.kibana_yaml.0.rendered
}

module "deploy_elastic_search" {
  count   = var.deploy_elastic_search ? 1 : 0
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id              = local.project.project_id
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
    local_file.elastic_search_yaml_output.0.filename,
    local_file.kibana_yaml_output.0.filename,
    kubernetes_namespace.elastic_search_namespace.0.id,
    kubernetes_service_account.elastic_search_identity.0.id
  ]
}
