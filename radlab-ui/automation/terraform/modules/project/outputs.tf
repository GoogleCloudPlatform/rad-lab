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

output "deployment_id" {
  description = "Unique identifier for the deployment."
  value       = local.random_id
}

output "name" {
  description = "Project name."
  value       = local.project.name
  depends_on = [
    google_project_organization_policy.boolean_policies,
    google_project_organization_policy.list_policies,
    google_project_service.project_services
  ]
}

output "number" {
  description = "Project number."
  value       = local.project.number
  depends_on = [
    google_project_organization_policy.boolean_policies,
    google_project_organization_policy.list_policies,
    google_project_service.project_services
  ]
}

output "project_id" {
  description = "Project ID"
  value       = local.project.project_id
  depends_on = [
    google_project_organization_policy.boolean_policies,
    google_project_organization_policy.list_policies,
    google_project_service.project_services
  ]
}
