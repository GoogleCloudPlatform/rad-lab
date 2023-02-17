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

module "vpc_nextflow" {
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
      subnet_ip             = var.ip_cidr_range
      subnet_region         = local.region
      description           = "Subnetwork inside nextflow VPC network, created via Terraform"
      subnet_private_access = true
    }
  ]

  firewall_rules = [
    {
      name        = "fw-nextflow-allow-internal"
      description = "Firewall rule to allow traffic on all ports inside *vpc-nextflow* VPC network."
      priority    = 65534
      ranges      = ["10.0.0.0/8"]
      direction   = "INGRESS"

      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    },
    {
      name        = "fw-nextflow-allow-iap"
      description = "Firewall rule to allow traffic on SSH and nextflow port to IAP range"
      priority    = 65534
      ranges      = ["35.235.240.0/20"]
      direction   = "INGRESS"
      target_tags = ["nextflow-iap"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]


    }
  ]

  depends_on = [
    google_project_service.enabled_services
  ]
}


module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  name          = "${var.network_name}-nat"
  project_id    = local.project.project_id
  region        = local.region
  network       = module.vpc_nextflow.0.network_name
  create_router = true
  router        = "${var.network_name}-nat-router"
}