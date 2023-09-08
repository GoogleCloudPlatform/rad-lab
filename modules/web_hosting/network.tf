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


#########################################################################
# vpc-xlb - VPC Network & Subnests
#########################################################################

resource "google_compute_network" "vpc_xlb" {
  name                    = var.network_name
  project                 = local.project.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.enabled_services]
}

# Creating Sunbet for vpc-xlb VPC network
resource "google_compute_subnetwork" "subnetwork_primary" {
  name                     = "vpc-subnet-primary"
  ip_cidr_range            = tolist(var.ip_cidr_ranges)[0]
  region                   = var.region
  network                  = google_compute_network.vpc_xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
}

# Creating Sunbet for vpc-xlb VPC network
resource "google_compute_subnetwork" "subnetwork_secondary" {
  name                     = "vpc-subnet-secondary"
  ip_cidr_range            = tolist(var.ip_cidr_ranges)[1]
  region                   = var.region_secondary
  network                  = google_compute_network.vpc_xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
}

#########################################################################
# Firewall Rules in vpc-xlb
#########################################################################

# FW rule for L7LB healthcheck
resource "google_compute_firewall" "fw_allow_lb_hc" {
  project = local.project.project_id
  name    = "fw-allow-lb-hc"
  network = google_compute_network.vpc_xlb.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# FW rule for SSH via IAP
resource "google_compute_firewall" "fw_allow_iap_ssh" {
  name    = "fw-allow-iap-ssh"
  network = resource.google_compute_network.vpc_xlb.name
  project = local.project.project_id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

# FW rule for Intra VPC
resource "google_compute_firewall" "fw_allow_intra_vpc" {
  name    = "fw-allow-intra-vpc"
  network = resource.google_compute_network.vpc_xlb.name
  project = local.project.project_id
  allow {
    protocol = "all"
  }
  source_ranges = var.ip_cidr_ranges
}


#########################################################################
# Creating Cloud NATs for Egress traffic from GCE VMs in vpc-xlb
#########################################################################

resource "google_compute_router" "cr_region_primary" {
  name    = "cr-${var.region}"
  project = local.project.project_id
  region  = google_compute_subnetwork.subnetwork_primary.region
  network = google_compute_network.vpc_xlb.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gw_region_primary" {
  name                               = "nat-gw-${var.region}"
  project                            = local.project.project_id
  router                             = google_compute_router.cr_region_primary.name
  region                             = google_compute_router.cr_region_primary.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "cr_region_secondary" {
  name    = "cr-${var.region_secondary}"
  project = local.project.project_id
  region  = google_compute_subnetwork.subnetwork_secondary.region
  network = google_compute_network.vpc_xlb.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gw_region_secondary" {
  name                               = "nat-gw-${var.region_secondary}"
  project                            = local.project.project_id
  router                             = google_compute_router.cr_region_secondary.name
  region                             = google_compute_router.cr_region_secondary.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


#########################################################################
# Enable Private Service Connect in vpc-xlb
#########################################################################

resource "google_compute_global_address" "psconnect_private_ip_alloc" {
  name          = "psconnect-ip-range"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 24
  network       = google_compute_network.vpc_xlb.id
  project       = local.project.project_id

  depends_on = [
    google_project_service.enabled_services
  ]
}


resource "google_service_networking_connection" "psconnect" {
  network                 = google_compute_network.vpc_xlb.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psconnect_private_ip_alloc.name]
}