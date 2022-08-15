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

resource "google_compute_network" "vpc-xlb" {
  name                    = "vpc-xlb"
  project                 = local.project.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.enabled_services]
}

# Creating Sunbet for vpc-xlb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-xlb-us-c1" {
  name                     = "vpc-xlb-us-c1"
  ip_cidr_range            = "10.200.20.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc-xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  # log_config {
  #   aggregation_interval = "INTERVAL_30_SEC"
  #   flow_sampling        = 0.5
  #   metadata             = "INCLUDE_ALL_METADATA"
  # }
}

# Creating Sunbet for vpc-xlb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-xlb-asia-s1" {
  name                     = "vpc-xlb-asia-s1"
  ip_cidr_range            = "10.200.240.0/24"
  region                   = "asia-south1"
  network                  = google_compute_network.vpc-xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  # log_config {
  #   aggregation_interval = "INTERVAL_30_SEC"
  #   flow_sampling        = 0.5
  #   metadata             = "INCLUDE_ALL_METADATA"
  # }
}

#########################################################################
# Firewall Rules in vpc-xlb
#########################################################################

# FW rule for L7LB healthcheck
resource "google_compute_firewall" "fw-vpc-xlb-lb-hc" {
  project       = local.project.project_id
  name          = "fw-vpc-xlb-lb-hc"
  network       = google_compute_network.vpc-xlb.name
 
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
  network       = google_compute_network.vpc-xlb.name
  priority      = 65534
  allow {
    protocol    = "icmp"
  }
 
  source_ranges = ["0.0.0.0/0"]
}

# FW rule for SSH via IAP
resource "google_compute_firewall" "fw-vpc-xlb-allow-iap-ssh" {
  name          = "fw-vpc-xlb-allow-iap-ssh"
  network       = resource.google_compute_network.vpc-xlb.name
  project       = local.project.project_id
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

#########################################################################
# vpc-ilb - VPC Network & Subnests
#########################################################################

resource "google_compute_network" "vpc-ilb" {
  name                    = "vpc-ilb"
  project                 = local.project.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.enabled_services]
}

# Creating Sunbet for vpc-ilb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-ilb-us-c1" {
  name                     = "vpc-ilb-us-c1"
  ip_cidr_range            = "10.100.20.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc-ilb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  # log_config {
  #   aggregation_interval = "INTERVAL_30_SEC"
  #   flow_sampling        = 0.5
  #   metadata             = "INCLUDE_ALL_METADATA"
  # }
}


#########################################################################
# Firewall Rules in vpc-xlb
#########################################################################

# FW rule for L7LB healthcheck
resource "google_compute_firewall" "fw-vpc-ilb-lb-hc" {
  project       = local.project.project_id
  name          = "fw-vpc-ilb-lb-hc"
  network       = google_compute_network.vpc-ilb.name
 
  allow {
    protocol    = "tcp"
    ports       = ["80"]
  }
 
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}


# FW rule for ICMP
resource "google_compute_firewall" "fw-vpc-ilb-allow-icmp" {
  project       = local.project.project_id
  name          = "fw-vpc-ilb-allow-icmp"
  network       = google_compute_network.vpc-ilb.name
  priority      = 65534
  allow {
    protocol    = "icmp"
  }
 
  source_ranges = ["0.0.0.0/0"]
}

# FW rule for SSH via IAP
resource "google_compute_firewall" "fw-vpc-ilb-allow-iap-ssh" {
  name          = "fw-vpc-ilb-allow-iap-ssh"
  network       = resource.google_compute_network.vpc-ilb.name
  project       = local.project.project_id
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}