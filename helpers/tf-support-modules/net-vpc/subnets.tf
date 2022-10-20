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
}

resource "google_compute_subnetwork" "default" {
  for_each                 = local.subnets
  project                  = var.project_id
  name                     = each.value.name
  network                  = local.network.name
  region                   = each.value.region
  ip_cidr_range            = each.value.cidr_range
  description              = try(each.value.description, "rad-lab-subnet")
  private_ip_google_access = each.value.enable_private_access
  secondary_ip_range = each.value.secondary_ip_ranges == null ? [] : [
    for name, range in each.value.secondary_ip_ranges :
    { range_name = name, ip_cidr_range = range }
  ]

  dynamic "log_config" {
    for_each = each.value.flow_logs_config != null ? [""] : []
    content {
      aggregation_interval = each.value.flow_logs_config.aggregation_interval
      filter_expr          = each.value.flow_logs_config.filter_expression
      flow_sampling        = each.value.flow_logs_config.flow_sampling
      metadata             = each.value.flow_logs_config.metadata
      metadata_fields = (
        each.value.flow_logs_config.metadata == "CUSTOM_METADATA"
        ? each.value.flow_logs_config.metadata_fields
        : null
      )
    }
  }
}