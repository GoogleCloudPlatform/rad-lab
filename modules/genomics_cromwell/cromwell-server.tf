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
data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-9"
}

//Create Cromwell service account and assign required roles
resource "google_service_account" "cromwell_service_account" {
  project      = local.project.project_id
  account_id   = format("cromwell-sa-%s", local.random_id)
  display_name = "Cromwell Service account"
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(local.cromwell_sa_project_roles)
  project  = local.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cromwell_service_account.email}"
}

resource "google_compute_instance" "cromwell_server" {
  project                   = local.project.project_id
  name                      = var.cromwell_server_instance_name
  machine_type              = var.cromwell_server_instance_type
  zone                      = var.default_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  network_interface {
    network    = module.vpc_cromwell.0.network_name
    subnetwork = module.vpc_cromwell.0.subnets["${local.region}/${var.network_name}"].self_link

  }
  tags = ["cromwell-iap"]

  metadata = {
    startup-script-url = "${google_storage_bucket.cromwell_workflow_bucket.url}/provisioning/bootstrap.sh"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.cromwell_service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
    google_storage_bucket_object.bootstrap,
    google_storage_bucket_object.config,
    google_storage_bucket_object.service
  ]
}


