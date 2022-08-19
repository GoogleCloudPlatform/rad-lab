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

output "project-radlab-alpha-fold-id" {
  description = "Alpha Fold Project ID"
  value       = local.project.project_id
}

output "workbench-instance-names" {
  description = "Vertex AI Workbench Names"
  value       = join(", ", google_notebooks_instance.workbench[*].name)
}

output "workbench-instance-locations" {
  description = "Vertex AI Workbench Names"
  value       = join(", ", google_notebooks_instance.workbench[*].location)
}

output "user-scripts-bucket-uri" {
  description = "User Script Bucket URI"
  value       = google_storage_bucket.user_scripts_bucket.self_link
}
