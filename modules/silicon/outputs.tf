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

output "billing_budget_budget_id" {
  sensitive   = true
  description = "Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}`"
  value       = var.create_budget ? google_billing_budget.budget[0].name : ""
}

output "deployment_id" {
  description = "RAD Lab Module Deployment ID"
  value       = local.random_id
}

output "project_id" {
  description = "Silicon RAD Lab Project ID"
  value       = local.project.project_id
}

output "notebooks_bucket_name" {
  description = "Notebooks GCS Bucket Name"
  value       = google_storage_bucket.notebooks_bucket.name
}

output "notebook_container_image" {
  description = "Container Image URI"
  value       = "${google_notebooks_instance.ai_notebook[0].container_image[0].repository}:${google_notebooks_instance.ai_notebook[0].container_image[0].tag}"
}

output "notebook_instance_names" {
  description = "Notebook Instance Names"
  value       = join(", ", google_notebooks_instance.ai_notebook[*].name)
}

output "notebook_urls" {
  description = "URLs for the notebook that was created in this module."
  value       = formatlist("https://%s", google_notebooks_instance.ai_notebook[*].proxy_uri)
  
  depends_on = [
    null_resource.ai_notebook_provisioning_state
  ]
}

output "artifact_registry_repository_id" {
  description = "Artifact Registry Repository ID"
  value       = google_artifact_registry_repository.containers_repo.repository_id
}

