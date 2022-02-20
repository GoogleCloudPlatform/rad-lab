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
  labels = length(var.labels) == 0 ? {
    origin = "rad-lab"
  } : merge(var.labels, { origin = "rad-lab" })
}

resource "random_id" "default" {
  byte_length = 2
}

module "slurm_project" {
  source = "../submodules/project"

  create_project     = var.create_project
  parent             = var.parent
  project_name       = var.project_name
  project_id         = format("%s-%s", var.project_name, random_id.default.hex)
  billing_account_id = var.billing_account_id
  labels             = local.labels

  project_services = [
    "compute.googleapis.com"
  ]
}

module "network" {
  source = "../submodules/network"

  create_vpc   = var.create_network
  network_name = var.network_name
  project_id   = module.slurm_project.project_id
  subnets      = var.subnets
}