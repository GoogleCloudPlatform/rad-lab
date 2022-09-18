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
 
 resource "google_sql_database_instance" "db_postgres" {
  database_version    = "POSTGRES_12"
  name                = format("test-radlab-web-hosting-db-%s", local.random_id)
  project             = local.project.project_id
  region              = "us-central1"
  deletion_protection = false
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
      point_in_time_recovery_enabled = true
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
  instance = google_sql_database_instance.db_postgres.name
  password = "radlab-sql-password"
}

#########################################################################
# Startup script for Sample DB VM in vpc-xlb
#########################################################################

data "template_file" "sample_db_metadata_startup_script" {
    # template = "${file("${path.module}/scripts/build/sample_db/sample_db_vm.sh")}"
    template = "${file("${path.module}/scripts/build/startup_scripts/sample_db/sample_db_vm.sh.tpl")}"
    vars = {
        DB_NAME = "postgres"
        DB_IP   = resource.google_sql_database_instance.db_postgres.private_ip_address
        DB_USER = resource.google_sql_user.users.name
        DB_PASS = resource.google_sql_user.users.password
    }
}

#########################################################################
# Creating GCE VM in vpc-xlb to spin up Sample DB in Postgres CLoud SQL
#########################################################################

resource "google_compute_instance" "sample-db-vm" {
  project      = local.project.project_id
  zone         = "us-central1-f"
  name         = "sample-db-vm"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.sample_db_metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.20.20"
    # access_config {
    #   // Ephemeral IP
    # }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }
  
  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-us-c1
    ]
}

resource "time_sleep" "create_sample_db" {

  create_duration = "60s"
  depends_on = [
      google_compute_instance.sample-db-vm,
      ]
}

#########################################################################
# Deleting GCE VM used to spin up Sample DB in Postgres CLoud SQL
#########################################################################

resource "null_resource" "del-sample-db-vm" {
  provisioner "local-exec" {
    command = "terraform destroy -auto-approve -lock=false --target google_compute_instance.sample-db-vm"
  }

  depends_on = [
    time_sleep.create_sample_db
  ]
}