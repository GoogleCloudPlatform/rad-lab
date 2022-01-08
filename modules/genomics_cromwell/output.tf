/**
 * Copyright 2021 Google LLC
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
  description = "Project ID where resrouces where created"
  value       = local.project.project_id
}
output "cromwell_server_instance_id" {
  description = "VM instance name running the Cromwell server"
  value       = google_compute_instance.cromwell_server.name
}
output "cromell_server_internal_IP" {
  description = "Cromwell server private IP address"
  value       = google_compute_instance.cromwell_server.network_interface[0].network_ip
}

output "cromwell_service_account_email" {
  description = "Email address of service account running the server and worker nodes"
  value       = google_service_account.cromwell_service_account.email
}

output "GCS_Bucket_URL" {
  description = "Google Cloud Storage Bucket configured for workflow execution"
  value       = google_storage_bucket.cromwell_workflow_bucket.url
}

