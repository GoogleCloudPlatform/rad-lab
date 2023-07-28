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


locals {
  random_id = var.deployment_id != null ? var.deployment_id : random_id.default.0.hex
  project = (var.create_project
    ? try(module.project_radlab_billing_budget.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  default_apis = [
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com"
    ]

  project_services = var.enable_services ? (var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis,["pubsub.googleapis.com"])) : local.default_apis) : []
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

###############
# GCP PROJECT #
###############

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "project_radlab_billing_budget" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = format("%s-%s", var.project_id_prefix, local.random_id)
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id

  activate_apis = []
}

resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

#########################################################################
# Creating GCE VMs in vpc-xlb
#########################################################################

data "google_compute_image" "debian_11_bullseye" {
  family  = "debian-11"
  project = "debian-cloud"
}

data "google_compute_zones" "available_zones" {
  project = local.project.project_id
  region  = var.region
  status  = "UP"
}

resource "google_compute_instance" "vm" {
  count                     = var.create_vm ? 1 : 0
  project                   = local.project.project_id
  zone                      = data.google_compute_zones.available_zones.names.0
  name                      = "radlab-vm"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = templatefile("${path.module}/scripts/build/sample_startup_script.sh.tpl", {})
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_11_bullseye.self_link
    }
  }

  network_interface {
    subnetwork         = local.subnet.self_link
    subnetwork_project = local.project.project_id
    access_config {
      // Ephemeral public IP
    }
  }

  depends_on = [
    time_sleep.wait_120_seconds,
  ]
}