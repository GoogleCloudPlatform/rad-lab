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
  subnets = {
    for subnet in var.subnets : "${subnet.region}/${subnet.name}" => subnet
  }

  network = (
    var.create_network
    ? try(google_compute_network.network.0, null)
    : try(data.google_compute_network.default.0, null)
  )
}

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = var.project_id
  name    = var.network_name
}

resource "google_compute_network" "network" {
  count                           = var.create_network ? 1 : 0
  project                         = var.project_id
  name                            = var.network_name
  description                     = var.description
  auto_create_subnetworks         = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_routes_on_create
  mtu                             = var.mtu
  routing_mode                    = var.routing_mode
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = local.subnets
  project       = var.project_id
  name          = each.value.name
  network       = local.network.name
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range
  secondary_ip_range = each.value.secondary_ip_range == null ? [] : [
    for name, range in each.value.secondary_ip_range :
    { range_name = name, ip_cidr_range = range }
  ]
  description              = "Managed by Terraform."
  private_ip_google_access = true
}