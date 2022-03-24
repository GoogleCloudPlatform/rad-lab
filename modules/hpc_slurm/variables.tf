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

variable "enable_services" {
  description = "Enable services on the project.  Set to false if using an existing project and the services have already been enabled."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created."
  type        = string
  default     = null
}

variable "ip_cidr_range" {
  description = "CIDR range for the subnet that hosts the HPC Slurm cluster."
  type        = string
  default     = "10.0.0.0/24"
}

variable "hpc_cluster_name" {
  description = "Name of the HPC cluster."
  type        = string
  default     = "hpc-slurm-cluster"
}

variable "hpc_controller_users" {
  description = "Users who should have access to the controller nodes."
  type        = set(string)
  default     = []
}

variable "hpc_controller_boot_disk_type" {
  description = "Disk type for the boot disk, attached to the controller."
  type        = string
  default     = "pd-standard"
}

variable "hpc_controller_boot_disk_size" {
  description = "Size of the boot disk of the controller node."
  type        = number
  default     = 50
}

variable "hpc_controller_machine_type" {
  description = "Machine type to be used for the Slurm controller."
  type        = string
  default     = "n1-standard-2"
}

variable "hpc_login_boot_disk_size" {
  description = "Size of the boot disk of the login node."
  type        = number
  default     = 20
}

variable "hpc_login_boot_disk_type" {
  description = "Disk type for the login nodes boot disk."
  type        = string
  default     = "pd-standard"
}

variable "hpc_login_machine_type" {
  description = "Machine type for the login node."
  type        = string
  default     = "n1-standard-2"
}

variable "hpc_login_users" {
  description = "Users who should have access to the login node."
  type        = set(string)
  default     = []
}

variable "hpc_node_prefix" {
  description = "Prefix for login node and controllers.  Will be suffixed with either '-login' or '-contr'."
  type        = string
  default     = "hpc-node"
}

variable "hpc_users" {
  description = "Users who should have access to all instances, as opposed to the individual instances."
  type        = set(string)
  default     = []
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

variable "organization_id" {
  description = "Organization ID where the project should be created.  This will act as the parent for the project."
  type        = string
  default     = null
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

variable "region" {
  description = "Default region to use for all resources, apart from subnets."
  type        = string
  default     = "us-central1"
}

variable "set_shielded_vm_policy" {
  description = "Enable shielded VM organization policy."
  type        = bool
  default     = false
}

variable "set_vpc_peering_policy" {
  description = "Set organization policy to enable VPC peering with certain projecst."
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "Name for the subnet.  Should match an existing subnet if deploying in an existing network."
  type        = string
  default     = "rad-hpc-slurm-snw"
}

