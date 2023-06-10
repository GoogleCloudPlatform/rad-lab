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
    ? try(module.vpc_network.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.vpc_network.0.subnets["${var.region}/${var.subnet_name}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )
}

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.subnet_name
  region  = var.region
}


#########################################################################
# vpc-network - VPC Network & Subnests
#########################################################################

module "vpc_network" {
  count   = var.create_network ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 5.1.0"

  project_id   = local.project.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.ip_cidr_range
      subnet_region         = var.region
      description           = "Subnetwork inside *vpc-analytics* VPC network, created via Terraform"
      subnet_private_access = true
    }
  ]

  firewall_rules = [
    {
      name        = "fw-allow-internal"
      description = "Firewall rule to allow traffic on all ports inside VPC network."
      priority    = 65534
      ranges      = ["10.0.0.0/8"]
      direction   = "INGRESS"

      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name        = "fw-allow-ssh"
      description = "Firewall rule to allow ssh on port 22."
      priority    = 65534
      ranges      = ["0.0.0.0/0"]
      direction   = "INGRESS"

      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ]

  depends_on = [
    module.project_radlab_billing_budget,
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]
}
