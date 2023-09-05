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

output "cromwell_server_instance_id" {
  description = "VM instance name running the Cromwell server"
  value       = google_compute_instance.cromwell_server.name
}

output "cromwell_server_zone" {
  description = "Google Cloud zone in which the server was provisioned"
  value       = var.zone
}

output "cromwell_server_internal_ip" {
  description = "Cromwell server private IP address"
  value       = google_compute_instance.cromwell_server.network_interface[0].network_ip
}

output "cromwell_service_account_email" {
  description = "Email address of service account running the server and worker nodes"
  value       = module.cromwell_service_account.email
}

output "gcs_bucket_url" {
  description = "Google Cloud Storage Bucket configured for workflow execution"
  value       = google_storage_bucket.cromwell_workflow_bucket.url
}

output "gcloud_iap_command" {
  description = "To connect to the Cromwell server using Identity Aware Proxy, run the following command"
  value       = "gcloud compute start-iap-tunnel ${google_compute_instance.cromwell_server.name} 8000 --local-host-port=localhost:8080 --zone=${var.zone} --project ${local.project.project_id}"
}

output "project_id" {
  description = "Project ID where resources where created"
  value       = local.project.project_id
}

