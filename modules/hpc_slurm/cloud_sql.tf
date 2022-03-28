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

resource "random_password" "db_password" {
  length      = 8
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 0
}

module "private_service_access" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = "10.0.0"

  project_id  = local.project.project_id
  vpc_network = local.network.name
}

module "private_sql_db_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "10.0.0"

  project_id           = local.project.project_id
  name                 = var.hpc_db_name
  random_instance_name = true

  database_version    = "MYSQL_8_0"
  deletion_protection = false
  region              = var.region
  zone                = data.google_compute_zones.zones.names[0]
  tier                = "db-n1-standard-1"

  ip_configuration = {
    ipv4_enabled        = false
    authorized_networks = []
    require_ssl         = false
    private_network     = local.network.self_link
    allocated_ip_range  = module.private_service_access.google_compute_global_address_name
  }

  additional_databases = [{
    name      = var.hpc_vars_db_name
    charset   = "utf8"
    collation = "utf8_general_ci"
  }]

  user_host     = "%"
  user_name     = var.hpc_vars_db_user
  user_password = random_password.db_password.result

  module_depends_on = [module.private_service_access.peering_completed]
}
