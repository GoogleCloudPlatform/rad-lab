/**
 * Copyright 2023 Google LLC
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
  elastic_search_identity_name = "es-demo-identity"
  k8s_namespace                = "elastic-search-demo"
}

module "deploy_eck_crds" {
  source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id                  = local.project.project_id
  cluster_name                = module.gke_cluster.name
  cluster_location            = var.region
  kubectl_create_command      = "kubectl create -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  kubectl_destroy_command     = "kubectl delete -f https://download.elastic.co/downloads/eck/1.8.0/crds.yaml"
  impersonate_service_account = length(var.resource_creator_identity) != 0 ? var.resource_creator_identity : ""
  skip_download               = true
  upgrade                     = false

  module_depends_on = [
    module.gke_cluster.endpoint,
  ]
}

module "deploy_eck_operator" {
  source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id                  = local.project.project_id
  cluster_name                = module.gke_cluster.name
  cluster_location            = var.region
  kubectl_create_command      = "kubectl apply -f https://download.elastic.co/downloads/eck/1.8.0/operator.yaml"
  kubectl_destroy_command     = "${path.module}/scripts/build/remove_eck_operator.sh"
  impersonate_service_account = length(var.resource_creator_identity) != 0 ? var.resource_creator_identity : ""
  skip_download               = true
  upgrade                     = false

  module_depends_on = [
    module.gke_cluster.endpoint, # Force dependency between modules
    module.deploy_eck_crds.wait,
  ]
}

resource "local_file" "elastic_search_yaml_output" {
  count    = var.deploy_elastic_search ? 1 : 0
  filename = "${path.module}/elk/elastic_search_deployment.yaml"
  content = templatefile("${path.module}/templates/elastic_search_deployment.yaml.tpl", {
    NAMESPACE           = local.k8s_namespace
    COUNT               = var.elastic_search_instance_count
    VERSION             = var.elk_version
    GCP_SERVICE_ACCOUNT = google_service_account.elastic_search_gcp_identity.email
    IDENTITY_NAME       = local.elastic_search_identity_name
  })
}

module "deploy_elastic_search" {
  count  = var.deploy_elastic_search ? 1 : 0
  source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id                  = local.project.project_id
  cluster_name                = module.gke_cluster.name
  cluster_location            = var.region
  kubectl_create_command      = "kubectl apply -f ${path.module}/elk"
  kubectl_destroy_command     = "kubectl delete -f ${path.module}/elk"
  impersonate_service_account = length(var.resource_creator_identity) != 0 ? var.resource_creator_identity : ""
  skip_download               = true
  upgrade                     = false
  use_existing_context        = false

  module_depends_on = [
    module.gke_cluster.endpoint,
    module.deploy_eck_crds.wait,
    module.deploy_eck_operator.wait,
    local_file.elastic_search_yaml_output.0.filename,
  ]
}
