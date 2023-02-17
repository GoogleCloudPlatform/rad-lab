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
data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-10"
}
//Create nextflow service account and assign required roles
module "nextflow_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 4.0"
  project_id   = local.project.project_id
  names        = ["nextflow-sa"]
  display_name = "nextflow Service account"
  description  = "Service Account used to run nextflow server and worker VMs"
}


resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.nextflow_sa_roles)
  project  = local.project.project_id
  role     = each.value
  member   = "serviceAccount:${module.nextflow_service_account.email}"
}

resource "google_service_account_iam_member" "nextflow_account_iam" {
  service_account_id = module.nextflow_service_account.service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.nextflow_service_account.email}"
}

resource "google_compute_instance" "nextflow_server" {
  project                   = local.project.project_id
  name                      = var.nextflow_server_instance_name
  machine_type              = var.nextflow_server_instance_type
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 50
    }
  }

  network_interface {
    network    = module.vpc_nextflow.0.network_name
    subnetwork = module.vpc_nextflow.0.subnets["${local.region}/${var.network_name}"].self_link

  }
  tags = ["nextflow-iap"]

  metadata = {
    startup-script-url = "${google_storage_bucket.nextflow_workflow_bucket.url}/${google_storage_bucket_object.bootstrap.name}"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = module.nextflow_service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
    google_storage_bucket_object.config,
    time_sleep.wait_120_seconds
  ]
}


