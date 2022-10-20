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


variable "auto_create_subnetworks" {
  description = "Create a default set of subnetworks on the network"
  type        = bool
  default     = false
}

variable "create_network" {
  description = "Indicate whether or not an existing network should be used or if a new one should be created.  If an existing network is created, ensure that var.name corresponds to the name of the network."
  type        = bool
  default     = true
}

variable "delete_default_routes_on_create" {
  description = "Delete the default routes when creating the network."
  type        = bool
  default     = false
}

variable "description" {
  description = "Description for the network"
  type        = string
  default     = "Network created by Terraform"
}

variable "mtu" {
  description = "MTU value for the network configuration.  The minimum value for this field is 1460 (the default) and the maximum value is 1500 bytes."
  type        = number
  default     = null
}

variable "name" {
  description = "The name of the network being created.  When using an existing network, make sure that this corresponds to the name of the existing network."
  type        = string
}

variable "project_id" {
  description = "Project ID where the network should be created.  When using an existing network, make sure that this value corresponds to the project ID hosting the network."
  type        = string
}

variable "routing_mode" {
  description = "The routing mode for the network (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
    error_message = "Routing mode must be GLOBAL or REGIONAL"
  }
}

variable "subnets" {
  description = "Subnet configuration"
  type = list(object({
    name                  = string
    cidr_range            = string
    region                = string
    description           = optional(string)
    enable_private_access = optional(bool, true)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string)
      filter_expression    = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
    }))
    secondary_ip_ranges = optional(map(string))
  }))
  default = []
}