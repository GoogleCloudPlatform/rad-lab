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
  non_confidential_dataset_id     = "non_confidential_dataset"
  confidential_dataset_id         = "secured_dataset"
  taxonomy_name                   = "secured_taxonomy"
  taxonomy_display_name           = "${local.taxonomy_name}-${local.random_id}"
  confidential_table_id           = "re_data"
  non_confidential_table_id       = "de_data"
  wrapped_key_secret_data         = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)
  bq_schema_dl                    = join(", ",[ for key, value in var.data_fields : "${key}:${value.type}" ])
  bigquery_non_confidential_table = "${module.project_radlab_sdw_non_conf_data.project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
  bigquery_confidential_table     = "${module.project_radlab_sdw_conf_data.project_id}:${local.confidential_dataset_id}.${local.confidential_table_id}"
}


module "secured_data_warehouse" {
  source  = "GoogleCloudPlatform/secured-data-warehouse/google"
  # version = "0.2.0"

  org_id                           = var.organization_id
  data_governance_project_id       = module.project_radlab_sdw_data_govern.project_id
  confidential_data_project_id     = module.project_radlab_sdw_conf_data.project_id
  non_confidential_data_project_id = module.project_radlab_sdw_non_conf_data.project_id
  data_ingestion_project_id        = module.project_radlab_sdw_data_ingest.project_id
  sdx_project_number               = module.template_project.sdx_project_number
  terraform_service_account        = var.secure_datawarehouse_service_acccount
  access_context_manager_policy_id = var.access_context_manager_policy_id
  bucket_name                      = format("radlab-bucket-%s", local.random_id)
  dataset_id                       = local.non_confidential_dataset_id
  confidential_dataset_id          = local.confidential_dataset_id
  cmek_keyring_name                = format("radlab-keyring-%s", local.random_id)
  pubsub_resource_location         = var.region
  location                         = var.region
  delete_contents_on_destroy       = var.delete_contents_on_destroy
  perimeter_additional_members     = local.perimeter_additional_members
  data_engineer_group              = var.data_engineer_group
  data_analyst_group               = var.data_analyst_group
  security_analyst_group           = var.security_analyst_group
  network_administrator_group      = var.network_administrator_group
  security_administrator_group     = var.security_administrator_group
  depends_on = [
    time_sleep.wait_120_seconds,
    module.iam_projects,
    module.centralized_logging,
    # google_project_iam_binding.remove_owner_role
  ]
}

resource "local_file" "deidentification_template_file" {
  filename  = format("${path.module}/templates/deidentification.tpl")
  content   = templatefile("${path.module}/templates/deidentification_template.tpl",
  {       
    display_name  = "$${display_name}"
    description   = "$${description}"
    crypto_key    = "$${crypto_key}"
    wrapped_key   = "$${wrapped_key}"
    template_id   = "$${template_id}"
    fields        = var.deidentified_fields
  })
}

module "de_identification_template" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/de-identification-template"

  project_id                = module.project_radlab_sdw_data_govern.project_id
  terraform_service_account = var.secure_datawarehouse_service_acccount
  crypto_key                = module.kek.keys[local.kek_key_name]
  wrapped_key               = local.wrapped_key_secret_data
  dlp_location              = var.region
  template_id_prefix        = "de_identification"
  template_file             = local_file.deidentification_template_file.filename
  dataflow_service_account  = module.secured_data_warehouse.dataflow_controller_service_account_email

}


resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = var.region
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"

  depends_on = [
    module.template_project,
    module.secured_data_warehouse
  ]
}

resource "google_artifact_registry_repository_iam_member" "confidential_docker_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = var.region
  repository = "flex-templates"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"

  depends_on = [
    module.template_project,
    module.secured_data_warehouse
  ]
}

resource "google_artifact_registry_repository_iam_member" "python_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = var.region
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.dataflow_controller_service_account_email}"

  depends_on = [
    module.template_project,
    module.secured_data_warehouse
  ]
}

resource "google_artifact_registry_repository_iam_member" "confidential_python_reader" {
  provider = google-beta

  project    = module.template_project.project_id
  location   = var.region
  repository = "python-modules"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"

  depends_on = [
    module.template_project,
    module.secured_data_warehouse
  ]
}

module "regional_deid_pipeline" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dataflow-flex-job"

  project_id              = module.project_radlab_sdw_data_ingest.project_id
  name                    = "dataflow-flex-regional-dlp-deid-job-python-query"
  container_spec_gcs_path = module.template_project.python_re_identify_template_gs_path
  job_language            = "PYTHON"
  region                  = var.region
  service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
  subnetwork_self_link    = module.dwh_networking_data_ingest.subnets_self_links[0]
  kms_key_name            = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.data_ingestion_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.data_ingestion_bucket_name}/staging/"

  parameters = {
    query                          = "SELECT ${join(", ",[ for key, value in var.data_fields : "${key}" ])} FROM [${module.project_radlab_sdw_data_ingest.project_id}:${module.sdw_data_ingest_bq_dataset.bigquery_dataset.dataset_id}.${module.sdw_data_ingest_bq_dataset.external_table_ids[0]}] "
    deidentification_template_name = module.de_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = var.region
    dlp_project                    = module.project_radlab_sdw_data_govern.project_id
    bq_schema                      = local.bq_schema_dl
    output_table                   = local.bigquery_non_confidential_table
    dlp_transform                  = "DE-IDENTIFY"
  }
}

resource "time_sleep" "wait_de_identify_job_execution" {
  create_duration = "720s"
  triggers = {
    time = timestamp()
  }
  depends_on = [
    module.regional_deid_pipeline
  ]
}

module "regional_reid_pipeline" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dataflow-flex-job"

  project_id              = module.project_radlab_sdw_conf_data.project_id
  name                    = "dataflow-flex-regional-dlp-reid-job-python-query"
  container_spec_gcs_path = module.template_project.python_re_identify_template_gs_path
  job_language            = "PYTHON"
  region                  = var.region
  service_account_email   = module.secured_data_warehouse.confidential_dataflow_controller_service_account_email
  subnetwork_self_link    = module.dwh_networking_conf.subnets_self_links[0]
  kms_key_name            = module.secured_data_warehouse.cmek_reidentification_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"

  parameters = {
    input_table                    = "${module.project_radlab_sdw_non_conf_data.project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
    deidentification_template_name = module.de_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = var.region
    dlp_project                    = module.project_radlab_sdw_data_govern.project_id
    bq_schema                      = local.bq_schema_dl
    output_table                   = local.bigquery_confidential_table
    dlp_transform                  = "RE-IDENTIFY"
  }
  depends_on = [
    time_sleep.wait_de_identify_job_execution,
    google_bigquery_table.re_id
  ]
}
