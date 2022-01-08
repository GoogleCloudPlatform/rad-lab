/**
 * Copyright 2021 Google LLC
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
module "cromwell-mysql-db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "8.0.0"


  name       = var.cromwell_db_name
  project_id = local.project.project_id

  deletion_protection = false

  database_version = "MYSQL_8_0"
  region           = local.region
  zone             = var.default_zone
  tier             = var.cromwell_db_tier

  additional_databases = [{ name = "cromwell", collation = "", charset = "" }]


  additional_users = [
    {
      name     = "cromwell"
      password = random_password.cromwell_db_pass.result
    }
  ]

  ip_configuration = {
    ipv4_enabled        = false,
    private_network     = module.vpc_cromwell.0.network_self_link,
    authorized_networks = [],
    require_ssl         = false
  }

  // Optional: used to enforce ordering in the creation of resources.
  module_depends_on = [module.private-service-access.peering_completed]
}