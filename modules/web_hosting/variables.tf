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

variable "billing_budget_calendar_period" {
  description = "A CalendarPeriod represents the abstract concept of a recurring time period that has a canonical start. Possible values are: MONTH, QUARTER, YEAR, CALENDAR_PERIOD_UNSPECIFIED {{UIMeta group=0 order=10 updatesafe options=MONTH,QUARTER,YEAR,CALENDAR_PERIOD_UNSPECIFIED }}"
  type        = string
  default     = "MONTH"
}

variable "billing_budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations. {{UIMeta group=0 order=11 updatesafe }}"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "billing_budget_labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget. {{UIMeta group=0 order=12 updatesafe }}"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.billing_budget_labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}

variable "billing_budget_services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/. {{UIMeta group=0 order=13 updatesafe }}"
  type        = list(string)
  default     = null
}

variable "billing_budget_notification_email_addresses" {
  description = "A list of email addresses which will be recieving billing budget notification alerts. A maximum of 5 channels are allowed. {{UIMeta group=0 order=14 updatesafe }}"
  type        = set(string)
  default     = []
  validation {
    condition     = length(var.billing_budget_notification_email_addresses) <= 5
    error_message = "Maximum of 5 email addresses are allowed for the budget monitoring channel."
  }
}

variable "billing_budget_pubsub_topic" {
  description = "If true, creates a Cloud Pub/Sub topic where budget related messages will be published. Default is false. {{UIMeta group=0 order=15 updatesafe }}"
  type        = bool
  default     = false
}

variable "create_budget" {
  description = "If the budget should be created. {{UIMeta group=0 order=5 updatesafe }}"
  type        = bool
  default     = false
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "db_activation_policy" {
  description = "This specifies when the instance should be active. {{UIMeta group=3 order=2 options=ALWAYS,NEVER,ON_DEMAND }}"
  type        = string
  default     = "ALWAYS"
}

variable "db_availability_type" {
  description = "The availability type of the Cloud SQL instance. {{UIMeta group=3 order=3 options=REGIONAL,ZONAL }}"
  type        = string
  default     = "REGIONAL"
}

variable "db_disk_type" {
  description = "The type of data disk. {{UIMeta group=3 order=4 options=PD_SSD,PD_HDD }}"
  type        = string
  default     = "PD_SSD"
}

variable "db_ipv4_enabled" {
  description = "Whether this Cloud SQL instance should be assigned a public IPV4 address. {{UIMeta group=3 order=6 }}"
  type        = bool
  default     = false
}

variable "db_tier" {
  description = "The machine type to use. Postgres supports only shared-core machine types, and custom machine types such as `db-custom-2-13312`. {{UIMeta group=3 order=5 }}"
  type        = string
  default     = "db-g1-small"
}

variable "db_version" {
  description = "PostgreSQL Server version to use. {{UIMeta group=3 order=1 options=POSTGRES_9_6,POSTGRES_10,POSTGRES_11,POSTGRES_12,POSTGRES_13,POSTGRES_14 }}"
  type        = string
  default     = "POSTGRES_12"

  validation {
    condition     = substr(var.db_version, 0, 8) == "POSTGRES"
    error_message = "Only POSTGRESQL Server is Supported."
  }
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

variable "ip_cidr_ranges" {
  description = "Unique IP CIDR Range for Primary & Secondary subnet. {{UIMeta group=2 order=4 }}"
  type        = set(string)
  default     = ["10.200.20.0/24", "10.200.240.0/24"]
}

variable "network_name" {
  description = "Name of the VPC network to be created. {{UIMeta group=2 order=1 }}"
  type        = string
  default     = "vpc-xlb"
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
  default     = "radlab-web-hosting"
}

variable "region" {
  description = "Primary region where the CloudSQL, Compute Instance and VPC subnet will be deployed. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "us-central1"
}

variable "region_secondary" {
  description = "Secondary region where the Compute Instance and VPC subnet will be deployed. {{UIMeta group=2 order=3 }}"
  type        = string
  default     = "asia-south1"
}

variable "resource_creator_identity" {
  description = "Terraform Service Account which will be creating the GCP resources. If not set, it will use user credentials spinning up the module. {{UIMeta group=0 order=4 updatesafe }}"
  type        = string
  default     = ""
}

variable "set_bucket_level_access_policy" {
  description = "Apply org policy to disable Uniform Bucket Level Access on GCS. {{UIMeta group=0 order=16 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_domain_restricted_sharing_policy" {
  description = "Enable org policy to allow all principals to be added to IAM policies. {{UIMeta group=0 order=17 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs. {{UIMeta group=0 order=18 updatesafe }}"
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