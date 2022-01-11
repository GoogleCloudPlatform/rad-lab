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
variable "cromwell_db_name" {
  description = "The name of the SQL Database instance"
  default     = "cromwelldb"
}

variable "cromwell_db_tier" {
  description = "CloudSQL tier, please refere to the documentation at https://cloud.google.com/sql/docs/mysql/instance-settings#machine-type-2ndgen ."
  type        = string
  default     = "db-n1-standard-2"

}
variable "cromwell_PAPI_endpoint" {
  description = "Endpoint for Life Sciences APIs. For locations other than us-central1, the endpoint needs to be updated to match the location For example for \"europe-west4\" location the endpoint-url should be \"https://europe-west4-lifesciences.googleapi/\""
  type        = string
  default     = "https://lifesciences.googleapis.com"
}
variable "cromwell_PAPI_location" {
  description = "Google Cloud region or multi-region where the Life Sciences API endpoint will be used. This does not affect where worker instances or data will be stored."
  type        = string
  default     = "us-central1"
}
variable "cromwell_port" {
  description = "Port Cromwell server will use for the REST API and web user interface."
  type        = string
  default     = "8000"
}
variable "cromwell_sa_roles" {
  description = "List of roles granted to the cromwell service account. This server account will be used to run both the Cromwell server and workers as well."
  type        = list(any)
  default = [
    "roles/lifesciences.workflowsRunner",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.objectAdmin",
    "roles/cloudsql.client",
    "roles/browser"
  ]
}

variable "cromwell_server_instance_name" {
  description = "Name of the VM instance that will be used to deploy Cromwell Server, this should be a valid Google Cloud instance name."
  type        = string
  default     = "cromwell-server"
}
variable "cromwell_server_instance_type" {
  description = "Cromwell server instance type"
  type        = string
  default     = "e2-standard-4"
}
variable "cromwell_version" {
  description = "Cromwell version that will be downloaded, for the latest release version, please check https://github.com/broadinstitute/cromwell/releases for the latest releases."
  type        = string
  default     = "72"

}


variable "cromwell_zones" {
  description = "GCP Zones that will be set as the default runtime in Cromwell config file."
  type        = list(any)
  default     = ["us-central1-a", "us-central1-b"]
}
variable "db_service_network_cidr_range" {
  description = "CIDR range used for the private service range for CloudSQL"
  type        = string
  default     = "10.128.50.0/24"
}

variable "default_region" {
  description = "The default region where the CloudSQL, Compute Instance and VPCs will be deployed"
  type        = string
  default     = "us-central1"
}
variable "default_zone" {
  description = "The default zone where the CloudSQL, Compute Instance be deployed"
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
  description = "Unique IP CIDR Range for cromwell subnet"
  type        = string
  default     = "10.142.190.0/24"
}

variable "network_name" {
  description = "This name will be used for VPC and subnets created"
  type        = string
  default     = "cromwell-vpc"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}
variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-gen-cromwell"
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

