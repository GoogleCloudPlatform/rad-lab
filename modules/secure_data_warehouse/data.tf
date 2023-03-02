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

data "google_storage_bucket" "sdw-data-ingest" {
  name = module.secured_data_warehouse.data_ingestion_bucket_name
  depends_on = [
    time_sleep.wait_120_seconds
  ]
}

resource "google_storage_bucket_object" "upload_sample_data" {
  for_each = length(var.source_data_gcs_objects) == 0 ? fileset("${path.module}/scripts/build/", "sample_data/*.csv") : toset([])
  name     = each.value
  source   = join("/", ["${path.module}/scripts/build/", each.value])
  bucket   = data.google_storage_bucket.sdw-data-ingest.name
}

data "google_storage_bucket_object_content" "external_data" {
  for_each  = length(var.source_data_gcs_objects) == 0 ? toset([]) : toset(var.source_data_gcs_objects)
  name      = replace(each.key, format("gs://%s/", split("/", trimprefix(each.key, "gs://"))[0]), "")
  bucket    = split("/", trimprefix(each.key, "gs://"))[0]
}

resource "google_storage_bucket_object" "upload_external_data" {
  for_each = length(var.source_data_gcs_objects) == 0 ? toset([]) : toset(var.source_data_gcs_objects)
  name     = join("/", ["sdw_data_ingest", reverse(split("/", each.key))[0]]) 
  content  = data.google_storage_bucket_object_content.external_data[each.key].content
  bucket   = data.google_storage_bucket.sdw-data-ingest.name
}

module "sdw_data_ingest_bq_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 5.2.0"

  project_id                  = module.project_radlab_sdw_data_ingest.project_id
  dataset_id                  = "sdw_data_ingest_dataset"
  dataset_name                = "sdw_data_ingest_dataset"
  description                 = "Ingested Data"
  location                    = var.region
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  external_tables = [
    {
      table_id              = "sdw_data_ingest_table"
      autodetect            = true
      compression           = null
      ignore_unknown_values = true
      max_bad_records       = 0
      source_format         = "CSV"
      schema                = null
      expiration_time       = null

      labels = {
      }
      source_uris = length(var.source_data_gcs_objects) == 0 ? ["${data.google_storage_bucket.sdw-data-ingest.url}/sample_data/*.csv"] : ["${data.google_storage_bucket.sdw-data-ingest.url}/sdw_data_ingest/*.csv"]
      csv_options = {
        quote                 = ""
        allow_jagged_rows     = false
        allow_quoted_newlines = false
        encoding              = "UTF-8"
        field_delimiter       = ","
        skip_leading_rows     = 1
      }
      hive_partitioning_options = null
      google_sheets_options     = null
    },
  ]
  depends_on = [
    google_storage_bucket_object.upload_sample_data,
    google_storage_bucket_object.upload_external_data
  ]
}