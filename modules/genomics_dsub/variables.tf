/**
 * Copyright 2021 Google LLC
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
  description = "Billing Account associated to the GCP Resources"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB attached to this instance"
  type        = number
  default     = 100
}

variable "boot_disk_type" {
  description = "Disk types for Lifesciences API instances"
  type        = string
  default     = "PD_SSD"
}

variable "domain" {
  description = "Display Name of Organization where GCP Resources need to get spin up"
  type        = string
  default     = ""
}

variable "file_path" {
  description = "Environment path to the respective modules (like DataScience module) which contains TF files for the same."
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "Folder ID in which GCP Resources need to get spin up"
  type        = string
  default     = ""
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for ngs subnet"
  type        = string
  default     = "10.142.190.0/24"
}

variable "machine_type" {
  description = "Type of VM you would like to spin up"
  type        = string
  default     = "n1-standard-2"
}

variable "network" {
  description = "Network associated to the project"
  type        = string
  default     = "ngs-network"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up"
  type        = string
}

variable "project_name" {
  description = "Name of the project that should be used."
  type        = string
  default     = "radlab-genomics"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`"
  type        = string
  default     = null
}

variable "region" {
  description = "Cloud Zone associated to the project"
  type        = string
  default     = "europe-west2"
}

variable "set_external_ip_policy" {
  description = "Enable org policy to allow External (Public) IP addresses on virtual machines."
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs."
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "Apply org policy to set the trusted image projects."
  type        = bool
  default     = true
}

variable "set_cloudfunctions_ingress_project_policy" {
  description = "Apply org policy to set the ingress settings for cloud functions"
  type        = bool
  default     = true
}

variable "subnet" {
  description = "Subnet associated with the Network"
  type        = string
  default     = "subnet-ngs-network"
}

variable "trusted_users" {
  description = "The list of trusted users."
  type        = set(string)
  default     = []
}

variable "zone" {
  description = "Cloud Zone associated to the project"
  type        = string
  default     = "europe-west2-*"
}