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

output "billing_budget_budget_id" {
  sensitive   = true
  description = "Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}`"
  value       = var.create_budget ? google_billing_budget.budget[0].name : ""
}

output "deployment_id" {
  description = "RADLab Module Deployment ID"
  value       = local.random_id
}

output "project_id_data_ingestion" {
  description = "Data Ingestion Project ID"
  value       = module.project_radlab_sdw_data_ingest.project_id
}

output "project_id_data_governance" {
  description = "Data Governance Project ID"
  value       = module.project_radlab_sdw_data_govern.project_id
}

output "project_id_confedential_data" {
  description = "Confedential Data Project ID"
  value       = module.project_radlab_sdw_conf_data.project_id
}

output "project_id_non_confedential_data" {
  description = "Non-Confedential Data Project ID"
  value       = module.project_radlab_sdw_non_conf_data.project_id
}
