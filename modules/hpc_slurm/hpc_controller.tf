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
  controller_node_access_users = setunion(var.hpc_controller_users, var.hpc_users)
}

resource "google_service_account" "hpc_slurm_controller_identity" {
  project     = local.project.project_id
  account_id  = "hpc-controller-id"
  description = "HPC Controller Identity"
}

resource "google_service_account_iam_member" "hpc_slurm_controller_access" {
  for_each           = local.controller_node_access_users
  member             = "user:${each.value}"
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.hpc_slurm_controller_identity.id
}

resource "google_compute_instance" "slurm_controller" {
  project      = local.project.project_id
  name         = format("%s-%s", var.hpc_node_prefix, "controller")
  zone         = data.google_compute_zones.zones.names[0]
  machine_type = var.hpc_controller_machine_type

  boot_disk {
    initialize_params {
      image = data.google_compute_image.schedmd_slurm_img.self_link
      type  = var.hpc_controller_boot_disk_type
      size  = var.hpc_controller_boot_disk_size
    }
  }

  network_interface {
    subnetwork = local.subnet.self_link
  }

  service_account {
    email  = google_service_account.hpc_slurm_controller_identity.email
    scopes = ["cloud-platform"]
  }

  tags = ["iap"]

  metadata = {
    enable-oslogin = "TRUE"
  }
}
