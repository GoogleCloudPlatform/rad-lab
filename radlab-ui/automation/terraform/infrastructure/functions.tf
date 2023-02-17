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

resource "null_resource" "create_function_init" {
  provisioner "local-exec" {
    command     = "npm install"
    working_dir = "${path.module}/function/create_deployment"
  }
}

data "archive_file" "cf_create_update_module_zip" {
  output_path = "${path.module}/create_build_fn.zip"
  type        = "zip"
  source_dir  = "${path.module}/function/create_deployment"

  depends_on = [
    null_resource.create_function_init
  ]
}

resource "google_storage_bucket_object" "cf_create_update_module_zip" {
  bucket       = google_storage_bucket.function_archive_storage.name
  name         = "cf_create_module.zip"
  content_type = "application/zip"
  source       = data.archive_file.cf_create_update_module_zip.output_path
}

resource "google_cloudfunctions_function" "create_update_module" {
  project               = module.project.project_id
  name                  = format("%s-%s", var.function_create_module_name, substr(data.archive_file.cf_create_update_module_zip.output_md5, 0, 5))
  runtime               = "nodejs16"
  description           = "Function that will trigger a Cloud Build job when a new module is created."
  entry_point           = "createRadLabModule"
  region                = var.region
  service_account_email = google_service_account.function_identity.email
  ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
  docker_registry       = "ARTIFACT_REGISTRY"

  source_archive_bucket = google_storage_bucket.function_archive_storage.name
  source_archive_object = google_storage_bucket_object.cf_create_update_module_zip.name

  available_memory_mb = 128
  timeout             = 60

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.radlab_ui_create.id
  }

  environment_variables = {
    PROJECT_ID             = module.project.project_id
    CREATE_TRIGGER_ID      = google_cloudbuild_trigger.create_radlab_module.name
    UPDATE_TRIGGER_ID      = google_cloudbuild_trigger.update_radlab_module.name
    DEPLOYMENT_BUCKET_NAME = google_storage_bucket.radlab_module_deployments_storage.name
    PARENT_FOLDER_ID       = split("/", local.parent_deployment_folder)[1]
    FIREBASE_PROJECT_ID    = module.project.project_id
  }

  depends_on = [
    data.archive_file.cf_delete_module_zip
  ]
}

resource "google_project_iam_member" "function_create_project_permissions" {
  for_each = toset([
    "roles/cloudbuild.builds.editor",
    "roles/logging.logWriter",
    "roles/datastore.owner"
  ])
  member  = "serviceAccount:${google_service_account.function_identity.email}"
  project = module.project.project_id
  role    = each.value
}

resource "google_storage_bucket_iam_member" "function_create_storage_permissions" {
  bucket = google_storage_bucket.radlab_module_deployments_storage.name
  member = "serviceAccount:${google_service_account.function_identity.email}"
  role   = "roles/storage.admin"
}

# Delete module

resource "null_resource" "delete_function_init" {
  provisioner "local-exec" {
    command     = "npm install"
    working_dir = "${path.module}/function/delete_deployment"
  }
}

data "archive_file" "cf_delete_module_zip" {
  output_path = "${path.module}/delete_build_fn.zip"
  type        = "zip"
  source_dir  = "${path.module}/function/delete_deployment"

  depends_on = [
    null_resource.delete_function_init
  ]
}

resource "google_storage_bucket_object" "cf_delete_module_zip" {
  bucket       = google_storage_bucket.function_archive_storage.name
  name         = "cf_delete_module.zip"
  content_type = "application/zip"
  source       = data.archive_file.cf_delete_module_zip.output_path
}

resource "google_cloudfunctions_function" "delete_module" {
  project               = module.project.project_id
  name                  = format("%s-%s", var.function_delete_module_name, substr(data.archive_file.cf_delete_module_zip.output_md5, 0, 5))
  runtime               = "nodejs16"
  description           = "Function that will trigger a Cloud Build job when a new module is created."
  entry_point           = "deleteRadLabModule"
  region                = var.region
  service_account_email = google_service_account.function_identity.email
  ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
  docker_registry       = "ARTIFACT_REGISTRY"

  source_archive_bucket = google_storage_bucket.function_archive_storage.name
  source_archive_object = google_storage_bucket_object.cf_delete_module_zip.name

  available_memory_mb = 128
  timeout             = 60

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.radlab_ui_delete.id
  }

  environment_variables = {
    PROJECT_ID             = module.project.project_id
    TRIGGER_ID             = google_cloudbuild_trigger.delete_radlab_module.name
    DEPLOYMENT_BUCKET_NAME = google_storage_bucket.radlab_module_deployments_storage.name
  }

  depends_on = [
    data.archive_file.cf_delete_module_zip
  ]
}

resource "google_service_account" "function_identity" {
  project     = module.project.project_id
  account_id  = var.function_create_identity_name
  description = "Service Account attached to the Cloud Function to manage RAD Lab modules."
}

resource "google_service_account_iam_member" "function_module_create_identity_impersonate_cloud_build_service_account" {
  member             = "serviceAccount:${google_service_account.function_identity.email}"
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.radlab_module_deployment_identity.id
}
