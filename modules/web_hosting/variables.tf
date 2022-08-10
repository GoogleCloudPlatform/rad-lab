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
  description = "Billing Account associated to the GCP Resources"
  type        = string
}

# variable "create_network" {
#   description = "If the module has to be deployed in an existing network, set this variable to false."
#   type        = bool
#   default     = true
# }

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false."
  type        = bool
  default     = true
}

variable "enable_services" {
  description = "Enable the necessary APIs on the project.  When using an existing project, this can be set to false."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. "
  type        = string
  default     = ""
}

# variable "ip_cidr_range" {
#   description = "Unique IP CIDR Range for Vertex AI Workbench subnet"
#   type        = string
#   default     = "10.142.190.0/24"
# }

# variable "machine_type" {
#   description = "Type of VM you would like to spin up"
#   type        = string
#   default     = "n1-standard-8"
# }

# variable "network_name" {
#   description = "Name of the network to be created."
#   type        = string
#   default     = "vertex-ai-workbench"
# }

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-web-hosting"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`"
  type        = string
  default     = null
}

# variable "set_external_ip_policy" {
#   description = "Enable org policy to allow External (Public) IP addresses on virtual machines."
#   type        = bool
#   default     = true
# }

variable "set_bucket_level_access_policy" {
  description = "Apply org policy to disable Uniform Bucket Level Access on GCS."
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs."
  type        = bool
  default     = true
}

# variable "set_trustedimage_project_policy" {
#   description = "Apply org policy to set the trusted image projects."
#   type        = bool
#   default     = true
# }

# variable "subnet_name" {
#   description = "Name of the subnet where to deploy the Notebooks."
#   type        = string
#   default     = "subnet-vertex-ai-workbench"
# }

variable "trusted_users" {
  description = "The list of trusted users."
  type        = set(string)
  default     = []
}

# variable "zone" {
#   description = "Cloud Zone associated to the Vertex AI Workbench"
#   type        = string
#   default     = "us-west1-b"
# }