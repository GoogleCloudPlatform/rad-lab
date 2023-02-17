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
 
module "dwh_networking_conf" {
  source                      = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dwh-networking"
  project_id                  = module.project_radlab_sdw_conf_data.project_id
  region                      = var.region
  vpc_name                    = "dataflow-conf-vpc"
  subnet_ip                   = "198.0.0.0/16"
  
  depends_on = [
    time_sleep.wait_120_seconds
  ]
}

module "dwh_networking_data_ingest" {
  source                      = "GoogleCloudPlatform/secured-data-warehouse/google//modules/dwh-networking"
  project_id                  = module.project_radlab_sdw_data_ingest.project_id
  region                      = var.region
  vpc_name                    = "dataflow-data-ingest-vpc"
  subnet_ip                   = "199.0.0.0/16"

  depends_on = [
    time_sleep.wait_120_seconds
  ]
}

