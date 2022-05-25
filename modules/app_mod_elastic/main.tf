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
  project_services = var.enable_apis ? [
    "compute.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ] : []

  organization_bool_policies = var.set_shielded_vm_policy ? { "constraints/compute.requireShieldedVm" : true } : {}
  organization_list_policies = var.set_vpc_peering_policy ? { "constraints/compute.restrictVpcPeering" : {
    inherit_from_parent = false
    suggested_value     = null
    status              = true
    values              = null
  } } : {}
}

module "elastic_search_project" {
  source = "../../helpers/tf-modules/project"

  project_name       = var.project_name
  create_project     = var.create_project
  parent             = var.folder_id != null ? "folders/${var.folder_id}" : "organizations/${var.organization_id}"
  random_id          = var.random_id
  billing_account_id = var.billing_account_id
  project_apis       = local.project_services
  org_policy_bool    = local.organization_bool_policies
  org_policy_list    = local.organization_list_policies
}

#resource "google_service_account" "elastic_search_gcp_identity" {
#  project      = local.project.project_id
#  account_id   = "elastic-search-id"
#  description  = "Elastic Search pod identity."
#  display_name = "Elastic Search Identity"
#
#  depends_on = [
#    module.elastic_search_project
#  ]
#}
#
#resource "google_service_account_iam_member" "elastic_search_k8s_identity" {
#  member             = "serviceAccount:${local.project.project_id}.svc.id.goog[${local.k8s_namespace}/${local.elastic_search_identity_name}]"
#  role               = "roles/iam.workloadIdentityUser"
#  service_account_id = google_service_account.elastic_search_gcp_identity.id
#
#  depends_on = [
#    module.gke_cluster
#  ]
#}
