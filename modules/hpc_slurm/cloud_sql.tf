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

resource "google_compute_global_address" "private_ip_address" {
  project       = local.project.project_id
  name          = "cloud-sql-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = local.network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = local.network.id
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  service                 = "servicenetworking.googleapis.com"

  depends_on = [
    google_project_service.enabled_services
  ]
}

resource "google_sql_database_instance" "slurm_db_instance" {
  project             = local.project.project_id
  database_version    = "MYSQL_8_0"
  name                = var.hpc_db_name
  region              = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = local.network.id
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}