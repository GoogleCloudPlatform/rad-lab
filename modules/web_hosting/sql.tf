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
  name                = format("radlab-web-hosting-db-%s", local.random_id)
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
# Configs for Sample DB Creation
#########################################################################

# Create Startup script for Sample DB VM in vpc-xlb
resource "local_file" "sample_db_metadata_startup_script_output" {
  filename = "${path.module}/scripts/build/startup_scripts/sample_db/sample_db_vm.sh"
  content = templatefile("${path.module}/scripts/build/startup_scripts/sample_db/sample_db_vm.sh.tpl", {
    DB_NAME = "postgres"
    DB_IP   = resource.google_sql_database_instance.db_postgres.private_ip_address
    DB_USER = resource.google_sql_user.users.name
    DB_PASS = resource.google_sql_user.users.password
  })
}

# Creating GCE VM used to spin up Sample DB in Postgres Cloud SQL
resource "null_resource" "create-sample-db-vm" {
  provisioner "local-exec" {

    command = <<-EOT
    if [ "${var.resource_creator_identity}" = "" ];
    then
        gcloud compute instances create sample-db-vm --zone=us-central1-f --project=${local.project.project_id} --machine-type=f1-micro --image=debian-11-bullseye-v20220822 --image-project=debian-cloud --network=${google_compute_network.vpc-xlb.name} --subnet=${google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name} --service-account=${google_service_account.sa_p_cloud_sql.email} --scopes=cloud-platform --no-address --metadata=enable-oslogin=true --metadata-from-file=startup-script=${local_file.sample_db_metadata_startup_script_output.filename}
    else
        gcloud compute instances create sample-db-vm --zone=us-central1-f --project=${local.project.project_id} --machine-type=f1-micro --image=debian-11-bullseye-v20220822 --image-project=debian-cloud --network=${google_compute_network.vpc-xlb.name} --subnet=${google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name} --service-account=${google_service_account.sa_p_cloud_sql.email} --scopes=cloud-platform --no-address --metadata=enable-oslogin=true --metadata-from-file=startup-script=${local_file.sample_db_metadata_startup_script_output.filename} --impersonate-service-account=${var.resource_creator_identity}
    fi
    EOT
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-us-c1
    ]
}

resource "time_sleep" "create_sample_db" {

  create_duration = "60s"
  depends_on = [
      null_resource.create-sample-db-vm,
      ]
}

# Deleting GCE VM used to spin up Sample DB in Postgres Cloud SQL
resource "null_resource" "del-sample-db-vm" {
  provisioner "local-exec" {
    command = <<-EOT
    if [ "${var.resource_creator_identity}" = "" ];
    then
        gcloud compute instances delete sample-db-vm --zone=us-central1-f --project=${local.project.project_id}
    else
        gcloud compute instances delete sample-db-vm --zone=us-central1-f --project=${local.project.project_id} --impersonate-service-account=${var.resource_creator_identity}
    fi
    EOT
  }

  depends_on = [
    time_sleep.create_sample_db
  ]
}