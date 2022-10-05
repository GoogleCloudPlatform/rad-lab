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


#########################################################################
# vpc-xlb - VPC Network & Subnests
#########################################################################

resource "google_compute_network" "vpc_xlb" {
  name                    = "vpc-xlb"
  project                 = local.project.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.enabled_services]
}

# Creating Sunbet for vpc-xlb VPC network
resource "google_compute_subnetwork" "subnetwork_vpc_xlb_us_c1" {
  name                     = "vpc-xlb-us-c1"
  ip_cidr_range            = "10.200.20.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
}

# Creating Sunbet for vpc-xlb VPC network
resource "google_compute_subnetwork" "subnetwork_vpc_xlb_asia_s1" {
  name                     = "vpc-xlb-asia-s1"
  ip_cidr_range            = "10.200.240.0/24"
  region                   = "asia-south1"
  network                  = google_compute_network.vpc_xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
}

#########################################################################
# Firewall Rules in vpc-xlb
#########################################################################

# FW rule for L7LB healthcheck
resource "google_compute_firewall" "fw-vpc-xlb-lb-hc" {
  project       = local.project.project_id
  name          = "fw-vpc-xlb-lb-hc"
  network       = google_compute_network.vpc_xlb.name
 
  allow {
    protocol    = "tcp"
    ports       = ["80"]
  }
 
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}


# FW rule for ICMP
resource "google_compute_firewall" "fw-vpc-xlb-allow-icmp" {
  project       = local.project.project_id
  name          = "fw-vpc-xlb-allow-icmp"
  network       = google_compute_network.vpc_xlb.name
  priority      = 65534
  allow {
    protocol    = "icmp"
  }
 
  source_ranges = ["0.0.0.0/0"]
}

# FW rule for SSH via IAP
resource "google_compute_firewall" "fw-vpc-xlb-allow-iap-ssh" {
  name          = "fw-vpc-xlb-allow-iap-ssh"
  network       = resource.google_compute_network.vpc_xlb.name
  project       = local.project.project_id
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}


# FW rule for Intra VPC
resource "google_compute_firewall" "fw-vpc-xlb-allow-intra-vpc" {
  name          = "fw-vpc-xlb-allow-intra-vpc"
  network       = resource.google_compute_network.vpc_xlb.name
  project       = local.project.project_id
  allow {
    protocol    = "all"
  }
  source_ranges = ["10.100.20.0/24","10.200.240.0/24"]
}


#########################################################################
# Creating Cloud NATs for Egress traffic from GCE VMs in vpc-xlb
#########################################################################

resource "google_compute_router" "cr_vpc_xlb_us_c1" {
  name    = "cr-vpc-xlb-us-c1"
  project = local.project.project_id
  region  = google_compute_subnetwork.subnetwork_vpc_xlb_us_c1.region
  network = google_compute_network.vpc_xlb.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gw_vpc_xlb_us_c1" {
  name                               = "nat-gw-vpc-xlb-us-c1"
  project                            = local.project.project_id
  router                             = google_compute_router.cr_vpc_xlb_us_c1.name
  region                             = google_compute_router.cr_vpc_xlb_us_c1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "cr_vpc_xlb_asia_s1" {
  name    = "cr-vpc-xlb-asia-s1"
  project = local.project.project_id
  region  = google_compute_subnetwork.subnetwork_vpc_xlb_asia_s1.region
  network = google_compute_network.vpc_xlb.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gw_vpc_xlb_asia_s1" {
  name                               = "nat-gw-vpc-xlb-asia-s1"
  project                            = local.project.project_id
  router                             = google_compute_router.cr_vpc_xlb_asia_s1.name
  region                             = google_compute_router.cr_vpc_xlb_asia_s1.region
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