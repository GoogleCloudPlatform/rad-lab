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

output "project_radlab_silicon_id" {
  description = "Analytics Project ID"
  value       = local.project.project_id
}

output "notebooks_instance_names" {
  description = "Notebook Instance Names"
  value       = join(", ", google_notebooks_instance.ai_notebook[*].name)
}

output "artifact_registry_repository_id" {
  description = "Artifact registry repository ID"
  value       = google_artifact_registry_repository.containers_repo.repository_id
}

output "notebooks_container_image" {
  description = "Artifact registry repository ID"
  value       = "${google_notebooks_instance.ai_notebook[0].container_image[0].repository}:latest}"
}
