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

variable "addresses" {
  description = "Optional list of external address (IPs) self links."
  type        = list(string)
  default     = []
}

variable "config_min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from this NAT config."
  type        = number
  default     = 64
}

variable "config_source_subnets" {
  description = "Subnetwork configuration (ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS)."
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "config_timeouts" {
  description = "Timeout configurations"
  type = object({
    icmp            = number
    tcp_established = number
    tcp_transitory  = number
    udp             = number
  })
  default = {
    icmp            = 30
    tcp_established = 1200
    tcp_transitory  = 30
    udp             = 30
  }
}

variable "logging_filter" {
  description = "Enables logging if not null, value is one of 'ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL'."
  type        = string
  default     = null
}

variable "create_router" {
  description = "Whether or not a router should be created, or an existing one should be used."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the Cloud NAT instance."
  type        = string
}

variable "project_id" {
  description = "Project where the Cloud NAT and routers will be deployed."
  type        = string
}

variable "region" {
  description = "Region where the Cloud NAT and Router will be created."
  type        = string
}

variable "router_asn" {
  description = "Router ASN used for the created router."
  type        = number
  default     = 64514
}

variable "router_name" {
  description = "When using an existing router, this should correspond to the existing router name."
  type        = string
  default     = null
}

variable "router_network" {
  description = "Name of the VPC used for the router."
  type        = string
  default     = null
}

variable "subnetworks" {
  description = "Subnetworks to NAT, only used when config_source_subnets equals LIST_OF_SUBNETWORKS."
  type = list(object({
    self_link            = string
    config_source_ranges = list(string)
    secondary_ranges     = list(string)
  }))
  default = []
}