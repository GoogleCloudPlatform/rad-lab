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
  description = "GCP Project ID"
  value       = local.project.project_id
}

output "vm" {
  description = "GCE VM Link"
  value       = var.create_vm ? "https://console.cloud.google.com/compute/instancesDetail/zones/${google_compute_instance.vm[0].zone}/instances/${google_compute_instance.vm[0].name}?project=${local.project.project_id}" : null

}

output "vm_external_access" {
  description = "GCE VM External IP"
  value       = var.create_vm ? "http://${google_compute_instance.vm[0].network_interface.0.access_config.0.nat_ip}" : null

}