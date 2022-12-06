locals {
  location                        = "us-east4"
  non_confidential_dataset_id     = "non_confidential_dataset"
  confidential_dataset_id         = "secured_dataset"
  confidential_table_id           = "dl_re_id"
  non_confidential_table_id       = "dl_de_id"
  wrapped_key_secret_data         = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)
  bq_schema_irs_990_ein           = "email:STRING, name:STRING, street:STRING, city:STRING, state:STRING, zip:INTEGER, dob:DATE, dl_id:STRING, exp_date:DATE, issue_date:DATE"
  bigquery_non_confidential_table = "${module.project_radlab_sdw_non_conf_data.project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
  bigquery_confidential_table     = "${module.project_radlab_sdw_conf_data.project_id}:${local.confidential_dataset_id}.${local.confidential_table_id}"
}

# module "regional_deid_pipeline" {
#   source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dataflow-flex-job"
#   project_id              = module.project_radlab_sdw_data_ingest.project_id
#   name                    = "dataflow-flex-regional-dlp-deid-job-python-query"
#   container_spec_gcs_path = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/${google_storage_bucket_object.template_upload.name}"
#   job_language            = "PYTHON"
#   region                  = local.location
#   service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
#   subnetwork_self_link    = module.dwh_networking_data_ingest.subnets_self_links[0]
#   kms_key_name            = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
#   temp_location           = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/tmp/"
#   staging_location        = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/staging/"

#   parameters = {
#     query                          = "SELECT email, name, street, city, state, zip, dob, dl_id, exp_date FROM [bigquery-public-data:irs_990.irs_990_ein] LIMIT 10000"
#     deidentification_template_name = module.de_identification_template.template_full_path
#     window_interval_sec            = 30
#     batch_size                     = 1000
#     dlp_location                   = local.location
#     dlp_project                    = module.project_radlab_sdw_data_govern.project_id
#     bq_schema                      = local.bq_schema_irs_990_ein
#     output_table                   = local.bigquery_confidential_table
#     dlp_transform                  = "RE-IDENTIFY"

#   }
# }


/*module "regional_reid_pipeline" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dataflow-flex-job"

  project_id              = module.project_radlab_sdw_conf_data.project_id
  name                    = "dataflow-flex-regional-dlp-reid-job-python-query"
  container_spec_gcs_path = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/${google_storage_bucket_object.template_upload.name}"
  job_language            = "PYTHON"
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
  subnetwork_self_link    = module.dwh_networking_conf.subnets_self_links[0]
  kms_key_name            = module.secured_data_warehouse.cmek_reidentification_crypto_key
  temp_location           = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/tmp/"
  staging_location        = "gs://${module.secured_data_warehouse.confidential_data_dataflow_bucket_name}/staging/"

  parameters = {
    input_table                    = "${module.project_radlab_sdw_non_conf_data.project_id}:${local.non_confidential_dataset_id}.${local.non_confidential_table_id}"
    deidentification_template_name = module.de_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = local.location
    dlp_project                    = module.project_radlab_sdw_data_govern.project_id
    bq_schema                      = local.bq_schema_irs_990_ein
    output_table                   = local.bigquery_confidential_table
    dlp_transform                  = "RE-IDENTIFY"
  }
}*/

/*resource "google_dataflow_job" "regional_deid" {
 project            = module.project_radlab_sdw_data_ingest.project_id
  name              = "dataflow-job"
  region                  = local.location
  service_account_email   = module.secured_data_warehouse.dataflow_controller_service_account_email
  kms_key_name            = module.secured_data_warehouse.cmek_data_ingestion_crypto_key
  template_gcs_path = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/${google_storage_bucket_object.template_upload.name}"
  temp_gcs_location = "gs://${data.google_storage_bucket.sdw-data-ingest.name}/tmp/"
  parameters = {
   query                          = "SELECT email, name, street, city, state, zip, dob, dl_id, exp_date FROM [bigquery-public-data:irs_990.irs_990_ein] LIMIT 10000"
    deidentification_template_name = module.de_identification_template.template_full_path
    window_interval_sec            = 30
    batch_size                     = 1000
    dlp_location                   = local.location
    dlp_project                    = module.project_radlab_sdw_data_govern.project_id
    bq_schema                      = local.bq_schema_irs_990_ein
    output_table                   = local.bigquery_confidential_table
    dlp_transform                  = "RE-IDENTIFY"
 
  }
}*/

