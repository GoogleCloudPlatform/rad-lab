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

resource "random_password" "cromwell_db_pass" {
  length  = 16
  special = false
}

module "cromwell_mysql_db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "~> 11.0"

  name       = var.cromwell_db_name
  project_id = local.project.project_id

  deletion_protection = false

  database_version = "MYSQL_8_0"
  region           = var.region
  zone             = var.zone
  tier             = var.cromwell_db_tier

  additional_databases = [{ name = "cromwell", collation = "", charset = "" }]

  additional_users = [
    {
      name     = "cromwell"
      password = random_password.cromwell_db_pass.result
    }
  ]

  ip_configuration = {
    authorized_networks = [],
    ipv4_enabled        = false,
    private_network     = module.vpc_cromwell.0.network_self_link,
    require_ssl         = false
    allocated_ip_range  = null
  }

  // Optional: used to enforce ordering in the creation of resources.
  module_depends_on = [google_service_networking_connection.private_service_access]
}