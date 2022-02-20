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
  network = (
    var.create_vpc
    ? try(google_compute_network.default.0, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnets = { for subnet in var.subnets : "${subnet.region}/${subnet.name}" => subnet }
}

data "google_compute_network" "default" {
  count   = var.create_vpc ? 0 : 1
  project = var.project_id
  name    = var.network_name
}

resource "google_compute_network" "default" {
  count                   = var.create_vpc ? 1 : 0
  project                 = var.project_id
  name                    = var.network_name
  description             = "Network created by RAD Lab."
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  for_each                 = local.subnets
  network                  = local.network.name
  name                     = each.value.name
  ip_cidr_range            = each.value.cidr_range
  description              = "RAD Lab subnet."
  private_ip_google_access = true
  project                  = var.project_id
  region                   = each.value.region

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}