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

locals {
  login_node_access_users = concat(var.hpc_users, var.hpc_login_users)
}

data "google_compute_zones" "zones" {
  project = local.project.project_id
  region  = var.region
}

resource "google_service_account" "hpc_login_identity" {
  project     = local.project.project_id
  account_id  = "hpc-login-identity"
  description = "Identity of the HPC Slurm Login node"
}

resource "google_service_account_iam_member" "hpc_login_user_access" {
  for_each           = local.login_node_access_users
  member             = each.value
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.hpc_login_identity.id
}

resource "google_compute_instance" "login_node" {
  project      = local.project.project_id
  name         = format("%s-%s", var.hpc_node_prefix, "login")
  machine_type = var.hpc_login_machine_type
  zone         = data.google_compute_zones.zones.names[0]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.schedmd_slurm_img.self_link
      type  = var.hpc_login_boot_disk_type
      size  = var.hpc_login_boot_disk_size
    }
  }

  network_interface {
    subnetwork = local.subnet.self_link
  }

  service_account {
    email  = google_service_account.hpc_login_identity.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

}