/**
 * Copyright 2022 Google LLC
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

output "deployment_id" {
  description = "RADLab Module Deployment ID"
  value       = local.random_id
}

output "project_id" {
  description = "Analytics Project ID"
  value       = local.project.project_id
}

output "notebooks-usermanaged-names" {
  description = "User Managed Notebook Instance Names"
  value       = join(", ", google_notebooks_instance.ai_notebook_usermanaged[*].name)
}

output "notebooks-usermanaged-locations" {
  description = "User Managed Notebook Instance Names"
  value       = join(", ", google_notebooks_instance.ai_notebook_usermanaged[*].location)
}

output "notebooks-googlemanaged-names" {
  description = "Google Managed Notebook Instance Names"
  value       = join(", ", google_notebooks_runtime.ai_notebook_googlemanaged[*].name)
}

output "notebooks-googlemanaged-locations" {
  description = "Google Managed Notebook Instance Names"
  value       = join(", ", google_notebooks_runtime.ai_notebook_googlemanaged[*].location)
}

output "user-scripts-bucket-uri" {
  description = "User Script Bucket URI"
  value       = google_storage_bucket.user_scripts_bucket.self_link
}
