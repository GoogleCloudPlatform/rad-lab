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
}

resource "random_id" "random_id" {
  count       = var.random_id == null ? 1 : 0
  byte_length = 2
}

module "slurm_project" {
  source = "../../helpers/tf_modules/project"

  billing_account_id = var.billing_account_id
  parent             = var.parent
  project_id         = var.project_id
  project_name       = var.project_name
  random_id          = local.random_id
  labels             = var.labels
}

module "slurm_network" {
  source = "../../helpers/tf_modules/vpc-net"

  project_id   = module.slurm_project.project_id
  network_name = "slurm-nw"
  subnets = [
    {
      name               = "euw1-slurm-snw"
      cidr_range         = "10.0.0.0/16"
      region             = "europe-west1"
      secondary_ip_range = null
    }
  ]
}