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
  # Allow users to either create their own random_id or use a generated one
  random_id = var.deployment_id != null ? var.deployment_id : random_id.default.0.hex
  project = (
    var.create_project
    ? try(module.elastic_search_project.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  default_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
  project_services = var.enable_services ? (var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis, ["pubsub.googleapis.com"])) : local.default_apis) : []
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "elastic_search_project" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = format("%s-%s", var.project_id_prefix, local.random_id)
  random_project_id = false
  org_id            = var.organization_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  create_project_sa = false

  activate_apis = []
}

resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    module.elastic_search_project
  ]
}

resource "google_service_account" "elastic_search_gcp_identity" {
  project      = local.project.project_id
  account_id   = "elastic-search-id"
  description  = "Elastic Search pod identity."
  display_name = "Elastic Search Identity"

  depends_on = [
    module.elastic_search_project
  ]
}

resource "google_service_account_iam_member" "elastic_search_k8s_identity" {
  member             = "serviceAccount:${local.project.project_id}.svc.id.goog[${local.k8s_namespace}/${local.elastic_search_identity_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.elastic_search_gcp_identity.id

  depends_on = [
    module.gke_cluster
  ]
}