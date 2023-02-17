/**
 * Copyright 2023 Google LLC
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
  description = "Billing Account associated to the GCP Resources.  {{UIMeta group=0 order=3 updatesafe }}"
  type        = string
}

variable "billing_budget_alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold. {{UIMeta group=0 order=6 updatesafe }}"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "billing_budget_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded. {{UIMeta group=0 order=7 updatesafe }}"
  type        = list(number)
  default     = [0.5, 0.7, 1]
}

variable "billing_budget_amount" {
  description = "The amount to use as the budget in USD. {{UIMeta group=0 order=8 updatesafe }}"
  type        = number
  default     = 500
}

variable "billing_budget_amount_currency_code" {
  description = "The 3-letter currency code defined in ISO 4217 (https://cloud.google.com/billing/docs/resources/currency#list_of_countries_and_regions). It must be the currency associated with the billing account. {{UIMeta group=0 order=9 updatesafe }}"
  type        = string
  default     = "USD"
}

variable "billing_budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations. {{UIMeta group=0 order=10 updatesafe }}"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "billing_budget_labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget. {{UIMeta group=0 order=11 updatesafe }}"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.billing_budget_labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}

variable "billing_budget_services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/. {{UIMeta group=0 order=12 updatesafe }}"
  type        = list(string)
  default     = null
}

variable "billing_budget_notification_email_addresses" {
  description = "A list of email addresses which will be recieving billing budget notification alerts. A maximum of 4 channels are allowed as the first element of `trusted_users` is automatically added as one of the channel. {{UIMeta group=0 order=13 updatesafe }}"
  type        = set(string)
  default     = []
  validation {
    condition     = length(var.billing_budget_notification_email_addresses) <= 4
    error_message = "Maximum of 4 email addresses are allowed for the budget monitoring channel."
  }
}

variable "billing_budget_pubsub_topic" {
  description = "If true, creates a Cloud Pub/Sub topic where budget related messages will be published. Default is false. {{UIMeta group=0 order=14 updatesafe }}"
  type        = bool
  default     = false
}

variable "create_budget" {
  description = "If the budget should be created. {{UIMeta group=0 order=5 updatesafe }}"
  type        = bool
  default     = false
}

variable "create_network" {
  description = "If the module has to be deployed in an existing network, set this variable to false. {{UIMeta group=2 order=1 }}"
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "cromwell_db_name" {
  description = "The name of the SQL Database instance. {{UIMeta group=3 order=1 }}"
  type        = string
  default     = "cromwelldb"
}

variable "cromwell_db_tier" {
  description = "CloudSQL tier, please refere to the documentation at https://cloud.google.com/sql/docs/mysql/instance-settings#machine-type-2ndgen. {{UIMeta group=3 order=2 }}"
  type        = string
  default     = "db-n1-standard-2"

}

variable "cromwell_PAPI_endpoint" {
  description = "Endpoint for Life Sciences APIs. For locations other than us-central1, the endpoint needs to be updated to match the location For example for \"europe-west4\" location the endpoint-url should be \"https://europe-west4-lifesciences.googleapi/\". {{UIMeta group=3 order=9 }}"
  type        = string
  default     = "https://lifesciences.googleapis.com"
}

variable "cromwell_PAPI_location" {
  description = "Google Cloud region or multi-region where the Life Sciences API endpoint will be used. This does not affect where worker instances or data will be stored. {{UIMeta group=3 order=10 }}"
  type        = string
  default     = "us-central1"
}

variable "cromwell_port" {
  description = "Port Cromwell server will use for the REST API and web user interface. {{UIMeta group=3 order=8 }}"
  type        = string
  default     = "8000"
}

variable "cromwell_sa_roles" {
  description = "List of roles granted to the cromwell service account. This server account will be used to run both the Cromwell server and workers as well. {{UIMeta group=3 order=11 updatesafe }}"
  type        = list(any)
  default = ["roles/lifesciences.workflowsRunner", "roles/serviceusage.serviceUsageConsumer", "roles/storage.objectAdmin", "roles/cloudsql.client", "roles/browser"]
}

variable "cromwell_server_instance_name" {
  description = "Name of the VM instance that will be used to deploy Cromwell Server, this should be a valid Google Cloud instance name. {{UIMeta group=3 order=4 }}"
  type        = string
  default     = "cromwell-server"
}

variable "cromwell_server_instance_type" {
  description = "Cromwell server instance type. {{UIMeta group=3 order=5 }}"
  type        = string
  default     = "e2-standard-4"
}

variable "cromwell_version" {
  description = "Cromwell version that will be downloaded, for the latest release version, please check https://github.com/broadinstitute/cromwell/releases for the latest releases. {{UIMeta group=3 order=6 }}"
  type        = string
  default     = "72"

}

variable "cromwell_zones" {
  description = "GCP Zones that will be set as the default runtime in Cromwell config file. {{UIMeta group=3 order=7 }}"
  type        = list(any)
  default     = ["us-central1-a", "us-central1-b"]
}

variable "db_service_network_cidr_range" {
  description = "CIDR range used for the private service range for CloudSQL. {{UIMeta group=3 order=3 }}"
  type        = string
  default     = "10.128.50.0/24"
}

variable "deployment_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`."
  type        = string
  default     = null
}

variable "enable_services" {
  description = "Enable the necessary APIs on the project.  When using an existing project, this can be set to false. {{UIMeta group=1 order=3 }}"
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. {{UIMeta group=0 order=2 updatesafe }}"
  type        = string
  default     = ""
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for cromwell subnet. {{UIMeta group=2 order=5 }}"
  type        = string
  default     = "10.142.190.0/24"
}

variable "network_name" {
  description = "This name will be used for VPC and subnets created. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "cromwell-vpc"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id. {{UIMeta group=0 order=1 }}"
  type        = string
  default     = ""
}

variable "owner_groups" {
  description = "List of groups that should be added as the owner of the created project. {{UIMeta group=1 order=6 updatesafe }}"
  type        = list(string)
  default     = []
}

variable "owner_users" {
  description = "List of users that should be added as owner to the created project. {{UIMeta group=1 order=7 updatesafe }}"
  type        = list(string)
  default     = []
}

variable "project_id_prefix" {
  description = "If `create_project` is true, this will be the prefix of the Project ID & name created. If `create_project` is false this will be the actual Project ID, of the existing project where you want to deploy the module. {{UIMeta group=1 order=2 }}"
  type        = string
  default     = "radlab-genomics-cromwell"
}

variable "region" {
  description = "The default region where the CloudSQL, Compute Instance and VPCs will be deployed. {{UIMeta group=2 order=3 }}"
  type        = string
  default     = "us-central1"
}

variable "resource_creator_identity" {
  description = "Terraform Service Account which will be creating the GCP resources. If not set, it will use user credentials spinning up the module. {{UIMeta group=0 order=4 updatesafe }}"
  type        = string
  default     = ""
}

variable "set_domain_restricted_sharing_policy" {
  description = "Enable org policy to allow all principals to be added to IAM policies. {{UIMeta group=0 order=15 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_external_ip_policy" {
  description = "If true external IP Policy will be set to allow all. {{UIMeta group=0 order=16 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_vpc_peering_policy" {
  description = "If true restrict VPC peering will be set to allow all. {{UIMeta group=0 order=17 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_shielded_vm_policy" {
  description = "If true shielded VM Policy will be set to disabled. {{UIMeta group=0 order=18 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_trustedimage_project_policy" {
  description = "If true trusted image projects will be set to allow all. {{UIMeta group=0 order=19 updatesafe }}"
  type        = bool
  default     = false
}

variable "trusted_groups" {
  description = "The list of trusted groups (e.g. `myteam@abc.com`). {{UIMeta group=1 order=5 updatesafe }}"
  type        = set(string)
  default     = []
}

variable "trusted_users" {
  description = "The list of trusted users (e.g. `username@abc.com`). {{UIMeta group=1 order=4 updatesafe }}"
  type        = set(string)
  default     = []
}

variable "zone" {
  description = "The default zone where the CloudSQL, Compute Instance be deployed. {{UIMeta group=2 order=4 }}"
  type        = string
  default     = "us-central1-a"
}