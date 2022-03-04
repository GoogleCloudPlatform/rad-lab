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

output "project_id" {
  description = "Project ID of the newly created project (or existing one)."
  value       = local.project.project_id
  depends_on  = [
    google_project.default,
    data.google_project.default,
    google_project_service.default,
  ]
}

output "project_number" {
  value      = local.project.project_number
  depends_on = [
    google_project.default,
    data.google_project.default,
    google_project_service.default,
  ]
}

output "random_id" {
  value = local.random_id
}