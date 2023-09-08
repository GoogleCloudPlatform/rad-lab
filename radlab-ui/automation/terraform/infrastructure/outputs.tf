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

output "admin_group_name" {
  value = var.admin_group_name
}

output "app_engine_url" {
  value = google_app_engine_application.radlab_ui.default_hostname
}

output "cloud_build_identity" {
  value = google_service_account.radlab_module_deployment_identity.email
}

output "create_topic_name" {
  value = google_pubsub_topic.radlab_ui_create.name
}

output "delete_topic_name" {
  value = google_pubsub_topic.radlab_ui_delete.name
}

output "function_create_name" {
  value = google_cloudfunctions_function.create_update_module.name
}

output "function_delete_name" {
  value = google_cloudfunctions_function.delete_module.name
}

output "git_personal_access_token_secret_id" {
  value = google_secret_manager_secret.git_repo_access_token.secret_id
}

output "git_repo_url" {
  value = var.git_repo_url
}

output "git_repo_branch" {
  value = element(split("/", var.git_ref), length(split("/", var.git_ref)) - 1)
}

output "module_deployment_bucket_name" {
  value = google_storage_bucket.radlab_module_deployments_storage.name
}

output "organization" {
  value = var.organization_name
}

output "project_id" {
  value = module.project.project_id
}

output "project_number" {
  value = module.project.number
}

output "service_account_module_creator" {
  value = google_service_account.radlab_module_deployment_identity.email
}

output "user_group_name" {
  value = var.user_group_name
}

output "webapp_identity_email" {
  value = google_service_account.radlab_ui_webapp_identity.email
}


