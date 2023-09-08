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
  network = (
    var.create_network
    ? try(module.elastic_search_network.0.network.network, null)
    : try(data.google_compute_network.existing_network.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.elastic_search_network.0.subnets["${var.region}/${var.subnet_name}"], null)
    : try(data.google_compute_subnetwork.existing_subnet.0, null)
  )
}

data "google_compute_network" "existing_network" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "existing_subnet" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.subnet_name
  region  = var.region
}

module "elastic_search_network" {
  count   = var.create_network ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = local.project.project_id
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
      range_name    = var.pod_ip_range_name
      ip_cidr_range = var.pod_cidr_block
      }, {
      range_name    = var.service_ip_range_name
      ip_cidr_range = var.service_cidr_block
    }]
  }

  depends_on = [
    module.elastic_search_project,
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]
}

// External access
resource "google_compute_router" "router" {
  count = var.enable_internet_egress_traffic ? 1 : 0

  project = local.project.project_id
  name    = "es-access-router"
  network = local.network.name
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_internet_egress_traffic ? 1 : 0
  project                            = local.project.project_id
  name                               = "es-proxy-ext-access-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_project_service.enabled_services
  ]
}

resource "google_compute_route" "external_access" {
  count            = var.enable_internet_egress_traffic ? 1 : 0
  project          = local.project.project_id
  dest_range       = "0.0.0.0/0"
  name             = "proxy-external-access"
  network          = local.network.name
  next_hop_gateway = "default-internet-gateway"
}

