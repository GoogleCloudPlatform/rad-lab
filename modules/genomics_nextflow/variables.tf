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
variable "create_network" {
  description = "If the module has to be deployed in an existing network, set this variable to false."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false."
  type        = bool
  default     = true
}


variable "nextflow_API_location" {
  description = "Google Cloud region or multi-region where the Life Sciences API endpoint will be used. This does not affect where worker instances or data will be stored."
  type        = string
  default     = "us-central1"
}

variable "nextflow_sa_roles" {
  description = "List of roles granted to the nextflow service account. This server account will be used to run both the nextflow server and workers as well."
  type        = list(any)
  default = [
    "roles/lifesciences.workflowsRunner",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.objectAdmin",
    "roles/batch.jobsAdmin",
    "roles/batch.agentReporter",
    "roles/batch.serviceAgent",
    "roles/iam.serviceAccountUser",
    "roles/browser",
    "roles/logging.viewer"
  ]
}

variable "nextflow_server_instance_name" {
  description = "Name of the VM instance that will be used to deploy nextflow Server, this should be a valid Google Cloud instance name."
  type        = string
  default     = "nextflow-server"
}
variable "nextflow_server_instance_type" {
  description = "nextflow server instance type"
  type        = string
  default     = "e2-standard-4"
}

variable "nextflow_zone" {
  description = "GCP Zone that will be set as the default runtime in nextflow config file."
  type        = string
  default     = "us-central1-a"
}

variable "default_region" {
  description = "The default region where the Compute Instance and VPCs will be deployed"
  type        = string
  default     = "us-central1"
}
variable "default_zone" {
  description = "The default zone where the Compute Instance be deployed"
  type        = string
  default     = "us-central1-a"
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
variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for nextflow subnet"
  type        = string
  default     = "10.142.190.0/24"
}

variable "network_name" {
  description = "This name will be used for VPC created"
  type        = string
  default     = "nextflow-vpc"
}

variable "subnet_name" {
  description = "This name will be used for subnet created"
  type        = string
  default     = "nextflow-vpc"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}
variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-genomics-nextflow"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`"
  type        = string
  default     = null
}

variable "set_external_ip_policy" {
  description = "If true external IP Policy will be set to allow all"
  type        = bool
  default     = false
}

variable "set_restrict_vpc_peering_policy" {
  description = "If true restrict VPC peering will be set to allow all"
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "If true shielded VM Policy will be set to disabled"
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "If true trusted image projects will be set to allow all"
  type        = bool
  default     = true
}

