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

module "sql_db_postgresql" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "12.1.0"

  database_version    = var.db_version
  name                = format("radlab-web-hosting-db-%s", local.random_id)
  project_id          = local.project.project_id
  region              = var.region
  deletion_protection = false
  activation_policy   = var.db_activation_policy
  availability_type   = var.db_availability_type

  backup_configuration = {
    enabled                        = true
    location                       = var.region
    point_in_time_recovery_enabled = true
    retained_backups               = 7
    retention_unit                 = "COUNT"
    start_time                     = "07:00"
    transaction_log_retention_days = 7
  }

  disk_autoresize       = true
  disk_autoresize_limit = 0
  disk_size             = 100
  disk_type             = var.db_disk_type

  ip_configuration = {
    authorized_networks = [],
    ipv4_enabled        = var.db_ipv4_enabled
    private_network     = google_compute_network.vpc_xlb.id
    require_ssl         = false
    allocated_ip_range  = null
  }

  pricing_plan = "PER_USE"
  zone         = data.google_compute_zones.primary_available_zones.names.2
  tier         = var.db_tier

  additional_users = [
    {
      name     = "radlab-sql-user"
      password = "radlab-sql-password"
    }
  ]

  module_depends_on = [google_service_networking_connection.psconnect, ]
}
#########################################################################
# Configs for Sample DB Creation
#########################################################################

# Create Startup script for Sample DB VM in vpc-xlb
resource "local_file" "sample_db_metadata_startup_script_output" {
  filename = "${path.module}/scripts/build/startup_scripts/sample_db/sample_db_vm.sh"
  content = templatefile("${path.module}/scripts/build/startup_scripts/sample_db/sample_db_vm.sh.tpl", {
    DB_NAME = "postgres"
    DB_IP   = module.sql_db_postgresql.private_ip_address
    DB_USER = module.sql_db_postgresql.additional_users[0].name
    DB_PASS = module.sql_db_postgresql.additional_users[0].password
  })
}

# Creating GCE VM used to spin up Sample DB in Postgres Cloud SQL
resource "null_resource" "create_sample_db_vm" {
  provisioner "local-exec" {

    command = <<-EOT
    if [ "${var.resource_creator_identity}" = "" ];
    then
        gcloud compute instances create sample-db-vm --zone=${data.google_compute_zones.primary_available_zones.names.2} --project=${local.project.project_id} --machine-type=f1-micro --image=debian-11-bullseye-v20220822 --image-project=debian-cloud --network=${google_compute_network.vpc_xlb.name} --subnet=${google_compute_subnetwork.subnetwork_primary.name} --service-account=${google_service_account.sa_p_cloud_sql.email} --scopes=cloud-platform --no-address --metadata=enable-oslogin=true --metadata-from-file=startup-script=${local_file.sample_db_metadata_startup_script_output.filename}
    else
        gcloud compute instances create sample-db-vm --zone=${data.google_compute_zones.primary_available_zones.names.2} --project=${local.project.project_id} --machine-type=f1-micro --image=debian-11-bullseye-v20220822 --image-project=debian-cloud --network=${google_compute_network.vpc_xlb.name} --subnet=${google_compute_subnetwork.subnetwork_primary.name} --service-account=${google_service_account.sa_p_cloud_sql.email} --scopes=cloud-platform --no-address --metadata=enable-oslogin=true --metadata-from-file=startup-script=${local_file.sample_db_metadata_startup_script_output.filename} --impersonate-service-account=${var.resource_creator_identity}
    fi
    EOT
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat_gw_region_primary
  ]
}

resource "time_sleep" "create_sample_db" {

  create_duration = "60s"
  depends_on = [
    null_resource.create_sample_db_vm,
  ]
}

# Deleting GCE VM used to spin up Sample DB in Postgres Cloud SQL
resource "null_resource" "del_sample_db_vm" {
  provisioner "local-exec" {
    command = <<-EOT
    if [ "${var.resource_creator_identity}" = "" ];
    then
        gcloud compute instances delete sample-db-vm --zone=${data.google_compute_zones.primary_available_zones.names.2} --project=${local.project.project_id}
    else
        gcloud compute instances delete sample-db-vm --zone=${data.google_compute_zones.primary_available_zones.names.2} --project=${local.project.project_id} --impersonate-service-account=${var.resource_creator_identity}
    fi
    EOT
  }

  depends_on = [
    time_sleep.create_sample_db
  ]
}