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
  description = "Create default subnets in each region."
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Indicate whether an existing VPC should be used or a new one should be created."
  type        = bool
  default     = true
}

variable "delete_default_routes_on_create" {
  description = "Delete default routes on create."
  type        = bool
  default     = false
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes.  Minimum value is 1460 and maximum value is 1500 bytes."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name for the network."
  type        = string
}

variable "project_id" {
  description = "Project ID where the network should be created."
  type        = string
}

variable "routing_mode" {
  description = "Routing mode for the network."
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
    error_message = "Routing mode must be GLOBAL or REGIONAL."
  }
}

variable "subnets" {
  description = "List of subnets to create on the network."
  type = list(object({
    name               = string
    cidr_range         = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = []
}