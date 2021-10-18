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

locals {
  random_id          = var.random_id != null ? var.random_id : random_id.random_id.hex
  project_name       = format("%s-%s", var.project_name, local.random_id)
  pod_range_name     = "pod-ip-range"
  service_range_name = "service-ip-range"
}

resource "random_id" "random_id" {
  byte_length = 2
}

module "elastic_search_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = local.project_name
  random_project_id = false
  org_id            = var.organization_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
}

module "elastic_search_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = module.elastic_search_project.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.network_cidr_block
      subnet_region         = var.region
      description           = "Subnetwork inside ${var.network_name} VPC network, created via Terraform"
      subnet_private_access = true

    }
  ]

  secondary_ranges = {
    "${var.subnet_name}" = [{ # Do not remove quotes, Terraform doesn't like variable references as map-keys without them
      range_name    = local.pod_range_name
      ip_cidr_range = var.pod_cidr_block
      }, {
      range_name    = local.service_range_name
      ip_cidr_range = var.service_cidr_block
    }]
  }
}