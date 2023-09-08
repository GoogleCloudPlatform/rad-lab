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

locals {

  data_ingest_bigquery_read_roles = [
    "roles/bigquery.jobUser",
    "roles/bigquery.dataEditor",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  governance_project_roles = [
    "roles/dlp.user",
    "roles/dlp.inspectTemplatesReader",
    "roles/dlp.deidentifyTemplatesReader"
  ]

  non_confidential_data_project_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]
}

resource "google_project_iam_member" "dfc_sa_sdw_data_ingest_roles" {
  for_each = toset(local.data_ingest_bigquery_read_roles)

  project = module.project_radlab_sdw_data_ingest.project_id
  role    = each.value
  member  = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_project_iam_member" "dfc_sa_sdw_data_govern_roles" {
  for_each = toset(local.governance_project_roles)

  project = module.project_radlab_sdw_data_govern.project_id
  role    = each.value
  member  = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_project_iam_member" "dfc_sa_sdw_non_conf_data_roles" {
  for_each = toset(local.non_confidential_data_project_roles)

  project = module.project_radlab_sdw_non_conf_data.project_id
  role    = each.value
  member  = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}

resource "google_service_account_iam_member" "terraform_sa_service_account_user" {
  service_account_id = "projects/${module.project_radlab_sdw_data_ingest.project_id}/serviceAccounts/${module.secured_data_warehouse.dataflow_controller_service_account_email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.secure_datawarehouse_service_acccount}"
}

resource "google_storage_bucket_iam_member" "dfc_sa_sdw_data_ingest_objectAdmin" {
  bucket = module.secured_data_warehouse.data_ingestion_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"
}