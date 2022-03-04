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

variable "billing_account_id" {
  description = "Billing Account ID to be assigned to the project."
  type        = string
}

variable "create_network" {
  description = "Whether or not to create a network or use an existing one."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Whether or not to create a project or use an existing one."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to be assigned to the resources."
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "Name for the network where HPC resources will be deployed."
  type        = string
  default     = "rad-hpc-slurm-nw"
}

variable "parent" {
  description = "Organization or Folder ID where the project should be created.  Has to be in the form organizations/XYZ or folders/XYZ."
  type        = string
  default     = null
}

variable "project_id" {
  description = "Project ID to be assigned to the project.  If a value is provided, it should correspond to an existing Project ID, as RAD Lab will try to deploy the resources in that project."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name to be used for the project."
  type        = string
  default     = "rad-hpc-slurm"
}

variable "random_id" {
  description = "Random ID to add to resources."
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnets to create on the network."
  type = list(object({
    name               = string
    cidr_range         = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = [{
    name               = "rad-hpc-slurm-snw-use1"
    cidr_range         = "10.0.0.0/16"
    region             = "us-east1"
    secondary_ip_range = null
  }]
}

