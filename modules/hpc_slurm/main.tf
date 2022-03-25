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
  random_id = var.random_id == null ? random_id.random_id.0.hex : var.random_id

  project_services = var.enable_services ? [
    "compute.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com"
  ] : []

  project = (var.create_project
    ? try(module.hpc_slurm_project.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  network = (
    var.create_network
    ? try(module.hpc_slurm_network.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.hpc_slurm_network.0.subnets["${var.region}/${var.subnet_name}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )
}

resource "random_id" "random_id" {
  count       = var.random_id == null ? 1 : 0
  byte_length = 2
}

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id
}

module "hpc_slurm_project" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = format("%s-%s", var.project_name, local.random_id)
  random_project_id = false
  org_id            = var.organization_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id

  activate_apis = []
}

resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    module.hpc_slurm_project
  ]
}