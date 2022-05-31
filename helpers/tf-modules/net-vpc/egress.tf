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

resource "google_compute_router" "default" {
  for_each = var.egress_traffic_config

  project = var.project_id
  name    = each.value.router_name
  network = local.network.name
  region  = each.value.region

  bgp {
    asn = each.value.bgp
  }
}

resource "google_compute_router_nat" "default" {
  for_each = var.egress_traffic_config

  name                               = each.value.nat_name
  nat_ip_allocate_option             = "AUTO_ONLY"
  router                             = ""
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}