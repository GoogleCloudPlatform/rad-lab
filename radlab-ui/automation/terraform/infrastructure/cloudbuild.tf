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

# Deploy a new RAD Lab module in the environment
resource "google_cloudbuild_trigger" "create_radlab_module" {
  project         = module.project.project_id
  name            = "rad-lab-module-create"
  description     = "Cloud Build triggered by Pub/Sub to create RAD Lab deployments."
  service_account = google_service_account.radlab_module_deployment_identity.id

  source_to_build {
    uri       = var.git_repo_url
    ref       = var.git_ref
    repo_type = var.git_repo_type
  }

  git_file_source {
    path      = "radlab-ui/automation/cloudbuild_create_deployment.yaml"
    repo_type = var.git_repo_type
    revision  = var.git_ref
    uri       = var.git_repo_url
  }

  substitutions = {
    _MODULE_NAME          = "DUMMY"
    _DEPLOYMENT_ID        = "DUMMY"
    _DEPLOYMENT_BUCKET_ID = google_storage_bucket.radlab_module_deployments_storage.name
    _TERRAFORM_IMAGE_NAME = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.terraform_builder_registry.name}/terraform"
  }

}

# Update an existing RAD Lab module
resource "google_cloudbuild_trigger" "update_radlab_module" {
  project         = module.project.project_id
  name            = "rad-lab-module-update"
  description     = "Cloud Build triggered by Pub/Sub to update RAD Lab deployments."
  service_account = google_service_account.radlab_module_deployment_identity.id

  source_to_build {
    uri       = var.git_repo_url
    ref       = var.git_ref
    repo_type = var.git_repo_type
  }

  git_file_source {
    path      = "radlab-ui/automation/cloudbuild_update_deployment.yaml"
    repo_type = var.git_repo_type
    revision  = var.git_ref
    uri       = var.git_repo_url
  }

  substitutions = {
    _MODULE_NAME          = "DUMMY"
    _DEPLOYMENT_ID        = "DUMMY"
    _DEPLOYMENT_BUCKET_ID = google_storage_bucket.radlab_module_deployments_storage.name
    _TERRAFORM_IMAGE_NAME = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.terraform_builder_registry.name}/terraform"
  }

}

# Delete an existing RAD Lab module
resource "google_cloudbuild_trigger" "delete_radlab_module" {
  project         = module.project.project_id
  name            = "rad-lab-module-delete"
  description     = "Cloud Build triggered by Pub/Sub to delete RAD Lab deployments."
  service_account = google_service_account.radlab_module_deployment_identity.id

  source_to_build {
    uri       = var.git_repo_url
    ref       = var.git_ref
    repo_type = var.git_repo_type
  }

  git_file_source {
    path      = "radlab-ui/automation/cloudbuild_delete_deployment.yaml"
    repo_type = var.git_repo_type
    revision  = var.git_ref
    uri       = var.git_repo_url
  }

  substitutions = {
    _MODULE_NAME          = "DUMMY"
    _DEPLOYMENT_ID        = "DUMMY"
    _DEPLOYMENT_BUCKET_ID = google_storage_bucket.radlab_module_deployments_storage.name
    _TERRAFORM_IMAGE_NAME = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.terraform_builder_registry.name}/terraform"
  }

}

# Purge deployments of all RAD Lab modules
resource "google_cloudbuild_trigger" "purge_radlab_modules" {
  project         = module.project.project_id
  name            = "rad-lab-module-purge"
  description     = "Cloud Build trigger to purge all RAD Lab module deployments."
  service_account = google_service_account.radlab_module_deployment_identity.id

  source_to_build {
    ref       = var.git_ref
    repo_type = var.git_repo_type
    uri       = var.git_repo_url
  }

  git_file_source {
    path      = "radlab-ui/automation/cloudbuild_purge_modules.yaml"
    repo_type = var.git_repo_type
    revision  = var.git_ref
    uri       = var.git_repo_url
  }

  substitutions = {
    _DEPLOYMENTS_BUCKET_NAME = google_storage_bucket.radlab_module_deployments_storage.name
    _TERRAFORM_IMAGE_NAME    = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.terraform_builder_registry.name}/terraform"
  }
}

