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
 
 resource "google_sql_database_instance" "db_mysql" {
  database_version = "MYSQL_5_7"
  name             = format("radlab-web-host-db-%s", local.random_id)
  project          = local.project.project_id
  region           = "us-central1"
  settings {
    activation_policy = "ALWAYS"
    availability_type = "REGIONAL"
    backup_configuration {
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
      enabled                        = true
      location                       = "us"
      binary_log_enabled             = true
      start_time                     = "07:00"
      transaction_log_retention_days = 7
    }
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 100
    disk_type             = "PD_SSD"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc-xlb.id
    }
    location_preference {
      zone = "us-central1-c"
    }
    pricing_plan = "PER_USE"
    tier         = "db-g1-small"
  }
  depends_on = [
    resource.google_service_networking_connection.psconnect,
  ]
}

resource "google_sql_user" "users" {
  project  = local.project.project_id
  name     = "radlab-sql-user"
  instance = google_sql_database_instance.db_mysql.name
  password = "radlab-sql-password"
}