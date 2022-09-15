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

variable "apis" {
  description = "The list of GCP apis to enable."
  type        = set(string)
  default     = ["compute.googleapis.com","bigquery.googleapis.com","bigquerystorage.googleapis.com"]
}

variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources"
  type        = string
}

variable "billing_budget_alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "billing_budget_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded"
  type        = list(number)
  default     = [0.5,0.7,1]
}

variable "billing_budget_amount" {
  description = "The amount to use as the budget in USD"
  type        = number
  default     = 1000
}

variable "billing_budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "billing_budget_labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.billing_budget_labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}

variable "billing_budget_services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/"
  type        = list(string)
  default     = null
}

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

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}

variable "owner_groups" {
  description = "List of groups that should be added as the owner of the created project"
  type        = list(string)
  default     = []
}

variable "owner_users" {
  description = "List of users that should be added as owner to the created project"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-billing-budget"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`"
  type        = string
  default     = null
}

variable "resource_creator_identity" {
  description = "Terraform Service Account which will be creating the GCP resources"
  type        = string
  default     = ""
}

variable "trusted_users" {
  description = "The list of trusted users who will be assigned Editor role on the project"
  type        = set(string)
  default     = []
}