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

# Identity to create RAD Lab modules (used by Cloud Build)
resource "google_service_account" "radlab_module_deployment_identity" {
  project      = module.project.project_id
  account_id   = var.project_creator_identity
  description  = "Service account that is responsible for creating and managing RAD Lab modules on the platform."
  display_name = var.project_creator_display_name
}

# RAD Lab Module Creator Identity IAM Permissions (Project, Folder, Billing)
resource "google_project_iam_member" "rad_lab_runner_identity_project_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator"
  ])
  member  = "serviceAccount:${google_service_account.radlab_module_deployment_identity.email}"
  project = module.project.project_id
  role    = each.value
}

resource "google_billing_account_iam_member" "rad_lab_runner_identity_billing_permissions" {
  for_each = var.set_billing_permissions ? toset([
    "roles/billing.user",
    "roles/billing.costsManager"
  ]) : []

  billing_account_id = local.radlab_module_billing_account
  member             = "serviceAccount:${google_service_account.radlab_module_deployment_identity.email}"
  role               = each.value
}

resource "google_folder_iam_member" "rad_lab_module_deployment_identity_folder_permissions" {
  for_each = toset([
    "roles/resourcemanager.projectCreator"
  ])
  folder = local.parent_deployment_folder
  member = "serviceAccount:${google_service_account.radlab_module_deployment_identity.email}"
  role   = each.value
}

# Permissions for Cloud Build to read and write to the Cloud Storage bucket.
resource "google_storage_bucket_iam_member" "cloud_build_storage_access" {
  bucket = google_storage_bucket.radlab_module_deployments_storage.name
  member = "serviceAccount:${google_service_account.radlab_module_deployment_identity.email}"
  role   = "roles/storage.admin"
}
