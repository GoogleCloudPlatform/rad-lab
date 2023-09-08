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

output "project_id" {
  description = "Project ID where resources where created"
  value       = local.project.project_id
}

output "nextflow_server_instance_id" {
  description = "VM instance name running the nextflow server"
  value       = google_compute_instance.nextflow_server.name
}

output "nextflow_server_zone" {
  description = "Google Cloud zone in which the server was provisioned"
  value       = var.zone
}

output "nextflow_service_account_email" {
  description = "Email address of service account running the server and worker nodes"
  value       = module.nextflow_service_account.email
}

output "gcs_bucket_url" {
  description = "Google Cloud Storage Bucket configured for workflow execution"
  value       = google_storage_bucket.nextflow_workflow_bucket.url
}

output "gcloud_ssh_command" {
  description = "To connect to the Nextflow instance using Identity Aware Proxy, run the following command"
  value       = "gcloud compute ssh ${google_compute_instance.nextflow_server.name} --zone=${var.zone} --project ${local.project.project_id}"
}

