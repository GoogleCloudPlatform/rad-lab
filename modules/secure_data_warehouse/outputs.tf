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

output "project_data_ingestion" {
  description = "Data Ingestion Project"
  value       = { "id"    =  "${module.project_radlab_sdw_data_ingest.project_id}"
                  "link"  = "https://console.cloud.google.com/welcome?project=${module.project_radlab_sdw_data_ingest.project_id}" }
}

output "project_data_governance" {
  description = "Data Governance Project"
  value       = { "id"    =  "${module.project_radlab_sdw_data_govern.project_id}"
                  "link"  = "https://console.cloud.google.com/welcome?project=${module.project_radlab_sdw_data_govern.project_id}" }
}

output "project_confedential_data" {
  description = "Confedential Data Project"
  value       = { "id"    =  "${module.project_radlab_sdw_conf_data.project_id}"
                  "link"  = "https://console.cloud.google.com/welcome?project=${module.project_radlab_sdw_conf_data.project_id}" }
}

output "project_non_confedential_data" {
  description = "Non-Confedential Data Project"
  value       = { "id"    =  "${module.project_radlab_sdw_non_conf_data.project_id}"
                  "link"  = "https://console.cloud.google.com/welcome?project=${module.project_radlab_sdw_non_conf_data.project_id}" }
}

output "project_template" {
  description = "Template Project"
  value       = { "id"    =  "${module.template_project.project_id}"
                  "link"  = "https://console.cloud.google.com/welcome?project=${module.template_project.project_id}" }
}

output "dataflow_controller_service_account_email" {
  description = "The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account."
  value       = module.secured_data_warehouse.dataflow_controller_service_account_email
}

output "storage_writer_service_account_email" {
  description = "The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.storage_writer_service_account_email
}

output "pubsub_writer_service_account_email" {
  description = "The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from."
  value       = module.secured_data_warehouse.pubsub_writer_service_account_email
}

output "data_ingestion_bucket_name" {
  description = "The name of the bucket created for the data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_bucket_name
}

output "data_ingestion_topic_name" {
  description = "The topic created for data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_topic_name
}

output "data_ingestion_bigquery_dataset" {
  description = "The bigquery dataset created for data ingestion pipeline."
  value       = module.secured_data_warehouse.data_ingestion_bigquery_dataset
}

output "cmek_data_ingestion_crypto_key" {
  description = "The Customer Managed Crypto Key for the data ingestion crypto boundary."
  value       = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
}

output "cmek_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the BigQuery service."
  value       = module.secured_data_warehouse.cmek_bigquery_crypto_key
}

output "cmek_reidentification_crypto_key" {
  description = "The Customer Managed Crypto Key for the reidentification crypto boundary."
  value       = module.secured_data_warehouse.cmek_reidentification_crypto_key
}

output "cmek_confidential_bigquery_crypto_key" {
  description = "The Customer Managed Crypto Key for the confidential BigQuery service."
  value       = module.secured_data_warehouse.cmek_confidential_bigquery_crypto_key
}

output "data_ingestion_access_level_name" {
  description = "Data Ingestion Access Context Manager access level name."
  value       = module.secured_data_warehouse.data_ingestion_access_level_name
}

output "data_ingestion_service_perimeter_name" {
  description = "Data Ingestion VPC Service Controls service perimeter name."
  value       = module.secured_data_warehouse.data_ingestion_service_perimeter_name
}

output "data_governance_access_level_name" {
  description = "Data Governance Access Context Manager access level name."
  value       = module.secured_data_warehouse.data_governance_access_level_name
}

output "data_governance_service_perimeter_name" {
  description = "Data Governance VPC Service Controls service perimeter name."
  value       = module.secured_data_warehouse.data_governance_service_perimeter_name
}

output "confidential_data_access_level_name" {
  description = "Confidential Data Access Context Manager access level name."
  value       = module.secured_data_warehouse.confidential_access_level_name
}

output "confidential_data_service_perimeter_name" {
  description = "Confidential Data VPC Service Controls service perimeter name"
  value       = module.secured_data_warehouse.confidential_service_perimeter_name
}

output "blueprint_type" {
  description = "Type of blueprint this module represents."
  value       = module.secured_data_warehouse.blueprint_type
}