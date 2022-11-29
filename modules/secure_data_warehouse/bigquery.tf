resource "google_bigquery_table" "sdw_non_conf_sample_data" {
  dataset_id = format("radlab_dataset_%s", local.random_id)
  table_id   = "non-conf-sample-data"
  project             = module.project_radlab_sdw_non_conf_data.project_id
  deletion_protection = false 
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote                 = ""
        allow_jagged_rows     = false 
        allow_quoted_newlines = false
        encoding              = "UTF-8"
        field_delimiter       = ","
        skip_leading_rows     = 1
    }

    source_uris = [
      "${data.google_storage_bucket.sdw-data-ingest.url}/${google_storage_bucket_object.file_upload.output_name}",
    ]
  }
}
