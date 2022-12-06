module "dwh_networking_conf" {
  source                      = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dwh-networking"
  project_id                  = module.project_radlab_sdw_conf_data.project_id
  region                      = "us-central1"
  vpc_name                    = "dataflow-conf-vpc"
  subnet_ip                   = "198.0.0.0/16"
}
module "dwh_networking_data_ingest" {
  source                      = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dwh-networking"
  project_id                  = module.project_radlab_sdw_data_ingest.project_id
  region                      = "us-central1"
  vpc_name                    = "dataflow-data-ingest-vpc"
  subnet_ip                   = "199.0.0.0/16"
}

