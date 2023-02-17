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

# Storage bucket for all RAD Lab deployments (files, terraform state, logs)
resource "google_storage_bucket" "radlab_module_deployments_storage" {
  project                     = module.project.project_id
  name                        = format("%s-%s", var.bucket_deployments_name, module.project.deployment_id)
  location                    = var.bucket_deployments_location
  force_destroy               = true
  uniform_bucket_level_access = true

  cors {
    origin          = ["https://${google_app_engine_application.radlab_ui.default_hostname}", "https://localhost:3000"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  versioning {
    enabled = var.bucket_deployments_versioning
  }
}

# Storage bucket for the RAD Lab UI Terraform state and other Admin objects
resource "google_storage_bucket" "radlab_ui_state_storage" {
  project                     = module.project.project_id
  name                        = format("%s-%s", var.bucket_admin_name, module.project.deployment_id)
  location                    = var.bucket_admin_location
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = var.bucket_admin_versioning
  }
}

# Storage bucket for function archives (.zip), so they can be deployed.
resource "google_storage_bucket" "function_archive_storage" {
  project                     = module.project.project_id
  location                    = var.bucket_function_deployments_location
  name                        = format("%s-%s", var.bucket_function_deployments_name, module.project.deployment_id)
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = var.bucket_function_deployments_versioning
  }
}

