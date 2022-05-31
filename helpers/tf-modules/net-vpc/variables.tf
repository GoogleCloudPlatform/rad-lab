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
  description = "Whether or not to create subnetworks automatically in every region, with a static IP range."
  type        = bool
  default     = false
}

variable "create_network" {
  description = "Whether or not to create a network, or use an existing one.  When using an existing one, 'network_name' should match the existing network."
  type        = bool
  default     = true
}

variable "delete_default_routes_on_create" {
  description = "Set to true to delete the default routes at creation time."
  type        = bool
  default     = false
}

variable "description" {
  description = "Description for the network."
  type        = string
  default     = "Managed by Terraform."
}

variable "network_name" {
  description = "Name of the network."
  type        = string
  default     = null
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes.  The minimum value for this field is 1460 and the maximum value is 1500 bytes."
  type        = number
  default     = null
}

variable "project_id" {
  description = "Project ID of the project where the network resources should be created."
  type        = string
  default     = null
}

variable "psa_config" {
  description = "The Private Service Access configuration for Service Networking."
  type = object({
    ranges = map(string)
    routes = object({
      export = bool
      import = bool
    })
  })
  default = null
}

variable "routing_mode" {
  description = "Network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
    error_message = "Routing mode must be GLOBAL or REGIONAL."
  }
}

variable "subnets" {
  description = "List of subnets."
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = []
}