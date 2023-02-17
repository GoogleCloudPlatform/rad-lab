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

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`. {{UIMeta group=0 order=17 }}"
  type        = string
  default     = ""
}

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

variable "confidential_tags" {
  description = "Provide list of confidential tags. {{UIMeta group=3 order=4 updatesafe}}"
  type        = map(object({
    display_name  = string
    description   = string
  }))
  default     = {
    name = {
        display_name    = "FULL_NAME"
        description     = "A full person name, which can include first names, middle names or initials, and last names."
    }
  }
}

variable "create_budget" {
  description = "If the budget should be created. {{UIMeta group=0 order=5 updatesafe }}"
  type        = bool
  default     = false
}

variable "dataset_location" {
  description = "The regional location for the dataset only US and EU are allowed in module. {{UIMeta group=2 order=3 }}"
  type        = string
  default     = "US"
}

variable "data_analyst_group" {
  description = "Google Cloud IAM group that analyzes the data in the warehouse. {{UIMeta group=1 order=10 updatesafe }}"
  type        = string
}

variable "data_engineer_group" {
  description = "Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. {{UIMeta group=1 order=11 updatesafe }}"
  type        = string
}

variable "deidentified_fields" {
  description = "Provide list of fields / columns need to get de-identified. {{UIMeta group=3 order=3 updatesafe}}"
  type        = list(string)
  default     = ["email", "dl_id"]
}

variable "deployment_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`."
  type        = string
  default     = null
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. {{UIMeta group=0 order=18 }}"
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. {{UIMeta group=0 order=2 updatesafe }}"
  type        = string
  default     = ""
}

variable "network_administrator_group" {
  description = "Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. {{UIMeta group=1 order=8 updatesafe }}"
  type        = string
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id. {{UIMeta group=0 order=1 }}"
  type        = string
  default     = ""
}

variable "owner_users" {
  description = "List of users that should be added as owner to the created project. {{UIMeta group=1 order=5 updatesafe }}"
  type        = list(string)
  default     = []
}

variable "owner_groups" {
  description = "List of groups that should be added as the owner of the created project. {{UIMeta group=1 order=4 updatesafe }}"
  type        = list(string)
  default     = []
}

variable "perimeter_additional_members" {
  description = "The list of all members (users or service accounts) to be added on perimeter access, except the service accounts created by this module. {{UIMeta group=1 order=9 updatesafe }}"
  type        = list(string)
}

variable "private_tags" {
  description = "Provide list of private tags. {{UIMeta group=3 order=5 updatesafe}}"
  type        = map(object({
    display_name  = string
    description   = string
  }))
  default     = {
    dob = {
        display_name    = "DOB"
        description     = "Date of Birth of the person."
    }
  }
}

variable "project_id_prefix" {
  description = "This will be the prefix of the Project ID & name created. {{UIMeta group=1 order=1 }}"
  type        = string
  default     = "radlab-sdw"
}

variable "region" {
  description = "The default region where the resources will be deployed. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "us-east4"
}

variable "resource_creator_identity" {
  description = "Terraform Service Account which will be creating the GCP resources. If not set, it will use user credentials spinning up the module. {{UIMeta group=0 order=4 updatesafe }}"
  type        = string
  default     = ""
}

variable "secure_datawarehouse_service_acccount" {
  description = "Terraform Service Account for Secure Data Warehouse module. NOTE: This should be same as RAD Lab UI Module creator Service Account. {{UIMeta group=1 order=12 updatesafe }}"
  type        = string
}

variable "data_fields" {
  description = "Data fields for schema of the data. List of `types` - https://cloud.google.com/bigquery/docs/schemas#standard_sql_data_types, List of mode - https://cloud.google.com/bigquery/docs/schemas#modes  . {{UIMeta group=3 order=2 updatesafe }}"
  type        = map(object({
    mode  = string
    type  = string
  }))
  default     = {
    email = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    name = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    street = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    city = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    state = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    zip = {
      mode  = "NULLABLE"
      type  = "INTEGER"
    },
    dob = {
      mode  = "NULLABLE"
      type  = "DATE"
    },
    dl_id = {
      mode  = "NULLABLE"
      type  = "STRING"
    },
    exp_date = {
      mode  = "NULLABLE"
      type  = "DATE"
    }
  }
}

variable "set_domain_restricted_sharing_policy" {
  description = "Enable org policy to allow all principals to be added to IAM policies. {{UIMeta group=0 order=15 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs. {{UIMeta group=0 order=16 updatesafe }}"
  type        = bool
  default     = false
}

variable "security_administrator_group" {
  description = "Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). {{UIMeta group=1 order=6 updatesafe }}"
  type        = string
}

variable "security_analyst_group" {
  description = "Google Cloud IAM group that monitors and responds to security incidents. {{UIMeta group=1 order=7 updatesafe }}"
  type        = string
}

variable "sensitive_tags" {
  description = "Provide list of sensitive tags. {{UIMeta group=3 order=6 updatesafe}}"
  type        = map(object({
    display_name  = string
    description   = string
  }))
  default     = {
    dl_id = {
        display_name    = "DRIVER_LICENSE_ID"
        description     = "Driver License document ID."
    }
  }
}

variable "source_data_gcs_objects" {
  description = "List of GCS URIs of the CSV data files. Example Format - 'gs://ci-bq-external-data/hive_partition_example/year=2012/foo.csv'. NOTE: Make sure that the RAD Lab UI module creator Service Account has read access to the GCS objects added to this list. {{UIMeta group=3 order=1 updatesafe }} "
  type        = list(string)
  default     = []
}

variable "subnet_ip" {
  description = "The CDIR IP range of the subnetwork. {{UIMeta group=2 order=1 }}"
  type        = string
  default     = "10.0.0.0/16"
}

variable "trusted_groups" {
  description = "The list of trusted groups (e.g. `myteam@abc.com`). {{UIMeta group=1 order=2 updatesafe }}"
  type        = set(string)
  default     = []
}

variable "trusted_users" {
  description = "The list of trusted users (e.g. `username@abc.com`). {{UIMeta group=1 order=3 updatesafe }}"
  type        = set(string)
  default     = []
}