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

module "slurm_db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "10.0.0"

  project_id          = local.project.project_id
  database_version    = var.hpc_db_version
  name                = format("%s-%s", var.hpc_db_name, local.random_id)
  region              = var.region
  zone                = data.google_compute_zones.zones.names[0]
  deletion_protection = false
  user_name           = var.hpc_vars_db_user

  ip_configuration = {
    authorized_networks = [{}]
    ip4_enabled         = true
    private_network     = ""
    require_ssl         = false
    allocated_ip_range  = ""
  }
}