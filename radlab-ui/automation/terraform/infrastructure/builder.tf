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

resource "google_service_account" "radlab_ui_automation_identity" {
  project      = module.project.project_id
  account_id   = var.ui_automation_identity_id
  description  = "Service account that will be used to automate the deployment of the UI."
  display_name = var.ui_automation_identity_name
}

resource "google_artifact_registry_repository" "terraform_builder_registry" {
  project       = module.project.project_id
  format        = "DOCKER"
  repository_id = var.terraform_builder_registry_id
  location      = var.region
}

resource "google_artifact_registry_repository_iam_member" "terraform_builder_registry_access" {
  member     = "serviceAccount:${google_service_account.radlab_ui_automation_identity.email}"
  repository = google_artifact_registry_repository.terraform_builder_registry.id
  role       = "roles/artifactregistry.writer"
}

resource "google_artifact_registry_repository_iam_member" "cloudbuild_registry_access" {
  member     = "serviceAccount:${google_service_account.radlab_module_deployment_identity.email}"
  repository = google_artifact_registry_repository.terraform_builder_registry.id
  role       = "roles/artifactregistry.reader"
}

module "terraform_builder" {
  source             = "../modules/tf-builder"
  project_id         = module.project.project_id
  terraform_checksum = var.terraform_builder_checksum
  terraform_version  = var.terraform_builder_version
  image_name         = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.terraform_builder_registry.name}/terraform"
}

resource "google_artifact_registry_repository" "appengine_registry" {
  project       = module.project.project_id
  description   = "Artifact Registry to be able to deploy App Engine, when redirects from GCR to AR has been configured on the project."
  format        = "DOCKER"
  repository_id = "us.gcr.io"
  location      = "us"
}


