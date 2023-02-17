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

resource "google_app_engine_application" "radlab_ui" {
  project       = module.project.project_id
  location_id   = var.app_engine_location
  database_type = "CLOUD_FIRESTORE"
}

resource "google_service_account" "radlab_ui_webapp_identity" {
  project      = module.project.project_id
  account_id   = var.webapp_identity
  description  = "Service account that should be attached to the webapp, running on App Engine"
  display_name = var.webapp_identity_display_name
}

resource "google_project_iam_member" "webapp_identity_permissions" {
  for_each = toset([
    "roles/iam.serviceAccountTokenCreator",
    "roles/datastore.user",
    "roles/storage.admin", #TODO: Only give permissions to the deployment bucket
    "roles/cloudbuild.builds.viewer",
    "roles/compute.viewer"
  ])
  project = module.project.project_id
  member  = "serviceAccount:${google_service_account.radlab_ui_webapp_identity.email}"
  role    = each.value
}

resource "local_file" "webapp_config_yaml" {
  filename = "../../../webapp/app.yaml"
  content = templatefile("${path.module}/templates/app.yaml.tpl", {
    UI_IDENTITY                   = google_service_account.radlab_ui_webapp_identity.email
    MODULE_DEPLOYMENT_BUCKET_NAME = google_storage_bucket.radlab_module_deployments_storage.name
  })
}
