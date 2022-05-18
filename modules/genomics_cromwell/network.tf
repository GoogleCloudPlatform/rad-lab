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

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
  region  = local.region
}

module "vpc_cromwell" {
  count   = var.create_network ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = local.project.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = var.network_name
      subnet_ip             = var.ip_cidr_range
      subnet_region         = local.region
      description           = "Subnetwork inside Cromwell VPC network, created via Terraform"
      subnet_private_access = true
    }
  ]

  firewall_rules = [
    {
      name        = "fw-cromwell-allow-internal"
      description = "Firewall rule to allow traffic on all ports inside *vpc-cromwell* VPC network."
      priority    = 65534
      ranges      = ["10.0.0.0/8"]
      direction   = "INGRESS"

      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name        = "fw-cromwell-allow-iap"
      description = "Firewall rule to allow traffic on SSH and Cromwell port to IAP range"
      priority    = 65534
      ranges      = ["35.235.240.0/20"]
      direction   = "INGRESS"
      target_tags = ["cromwell-iap"]
      allow = [{
        protocol = "tcp"
        ports    = ["22", "${var.cromwell_port}"]
      }]


    }
  ]

  depends_on = [
    google_project_service.enabled_services
  ]
}


module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  name          = "${var.network_name}-nat"
  project_id    = local.project.project_id
  region        = local.region
  network       = module.vpc_cromwell.0.network_name
  router        = "${var.network_name}-nat-router"
  create_router = true
}

module "private-service-access" {
  source        = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version       = "8.0.0"
  project_id    = local.project.project_id
  vpc_network   = module.vpc_cromwell.0.network_name
  address       = split("/", var.db_service_network_cidr_range)[0]
  prefix_length = split("/", var.db_service_network_cidr_range)[1]

  depends_on = [
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]

}
