# /**
#  * Copyright 2022 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

# locals {
#   docker_repository_url = "${var.location}-docker.pkg.dev/${module.project_radlab_sdw_data_ingest.project_id}/${google_artifact_registry_repository.flex_templates.name}"
#   python_repository_url = "${var.location}-python.pkg.dev/${module.project_radlab_sdw_data_ingest.project_id}/${google_artifact_registry_repository.python_modules.name}"
# }

# resource "google_project_service_identity" "cloudbuild_sa" {
#   provider = google-beta

#   project = module.project_radlab_sdw_data_ingest.project_id
#   service = "cloudbuild.googleapis.com"

# }

# resource "google_project_iam_member" "cloud_build_builder" {
#   project = module.project_radlab_sdw_data_ingest.project_id
#   role    = "roles/cloudbuild.builds.builder"
#   member  = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
# }

# resource "google_artifact_registry_repository" "flex_templates" {
#   provider = google-beta

#   project       = module.project_radlab_sdw_data_ingest.project_id
#   location      = var.location
#   repository_id = var.docker_repository_id
#   description   = "DataFlow Flex Templates"
#   format        = "DOCKER"
# }

# resource "google_artifact_registry_repository_iam_member" "docker_writer" {
#   provider = google-beta

#   project    = module.project_radlab_sdw_data_ingest.project_id
#   location   = var.location
#   repository = var.docker_repository_id
#   role       = "roles/artifactregistry.writer"
#   member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"

# }

# resource "google_artifact_registry_repository" "python_modules" {
#   provider = google-beta

#   project       = module.project_radlab_sdw_data_ingest.project_id
#   location      = var.location
#   repository_id = var.python_repository_id
#   description   = "Repository for Python modules for Dataflow flex templates"
#   format        = "PYTHON"
# }

# resource "google_artifact_registry_repository_iam_member" "python_writer" {
#   provider = google-beta

#   project    = module.project_radlab_sdw_data_ingest.project_id
#   location   = var.location
#   repository = var.python_repository_id
#   role       = "roles/artifactregistry.writer"
#   member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"

# }

# resource "google_storage_bucket" "templates_bucket" {
#   name     = "bkt-${module.project_radlab_sdw_data_ingest.project_id}-tpl-${local.random_id}"
#   location = var.location
#   project  = module.project_radlab_sdw_data_ingest.project_id

#   force_destroy               = true
#   uniform_bucket_level_access = true
  
# }

