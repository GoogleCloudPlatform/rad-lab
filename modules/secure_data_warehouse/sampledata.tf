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
 
data "google_storage_bucket" "sdw-data-ingest" {
  name = module.secured_data_warehouse.data_ingestion_bucket_name
}

resource "google_storage_bucket_object" "file_upload" {
  name   = "drivers_license"
  bucket = module.secured_data_warehouse.data_ingestion_bucket_name
  source = "${path.module}/scripts/build/dataset/drivers_license.csv"
}

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
