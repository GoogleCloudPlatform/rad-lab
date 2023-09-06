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
  description = "RADLab Module Deployment ID"
  value       = local.random_id
}

output "project_id" {
  description = "Alpha Fold Project ID"
  value       = local.project.project_id
}

output "user_scripts_bucket_uri" {
  description = "User Script Bucket URI"
  value       = google_storage_bucket.user_scripts_bucket.self_link
}

output "workbench_instance_names" {
  description = "Vertex AI Workbench Names"
  value       = join(", ", google_notebooks_instance.workbench[*].name)
}

output "workbench_instance_urls" {
  description = "Vertex AI Workbench Notebook URLS"
  value       = formatlist("https://%s", google_notebooks_instance.workbench[*].proxy_uri)
  
  depends_on = [
    null_resource.workbench_provisioning_state
  ]

}

