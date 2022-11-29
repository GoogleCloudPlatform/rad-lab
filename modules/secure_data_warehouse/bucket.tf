data "google_storage_bucket" "sdw-data-ingest" {
  name = module.secured_data_warehouse.data_ingestion_bucket_name
}
resource "google_storage_bucket_object" "file_upload" {
  name   = "drivers_license"
  bucket = module.secured_data_warehouse.data_ingestion_bucket_name
  source = "${path.module}/dataset/drivers_license.csv"
}
