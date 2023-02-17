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

variable "ah_data_exchange_id" {
  description = "Analytics Hub : Data Exchange ID (shared with `allauthenticated` users). {{UIMeta group=4 order=2 }}"
  type        = string
  default     = "National_Ecological_Observatory_Network_NEON_pilot"
}

variable "ah_data_exchange_location" {
  description = "Analytics Hub : Data Exchange Location. {{UIMeta group=4 order=3 }}"
  type        = string
  default     = "us-central1"
}

variable "ah_listing_dataset_map" {
  description = "Analytics Hub : Listing ID and Linked Dataset display name key value pair. {{UIMeta group=4 order=4 }}"
  type        = map(string)
  default = {"neon_chemical_properties_of_surface_water" = "neon_chemical_properties_of_surface_water", "neon_continuous_discharge" = "neon_continuous_discharge"}
}

variable "ah_project_id" {
  description = "Analytics Hub : Project ID (associated to the data exchange & listing). {{UIMeta group=4 order=1 }}"
  type        = string
  default     = "neon-nonprod-bq-datasets"
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

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB attached to this instance.  {{UIMeta group=3 order=8 options=50,100,500 }}"
  type        = number
  default     = 100
}

variable "boot_disk_type" {
  description = "Disk types for notebook instances. {{UIMeta group=3 order=7 }}"
  type        = string
  default     = "PD_SSD"
}

variable "create_budget" {
  description = "If the budget should be created. {{UIMeta group=0 order=5 updatesafe }}"
  type        = bool
  default     = false
}

variable "create_container_image" {
  description = "If the notebook needs to have image type as Container set this variable to true, set it to false when using dafault image type i.e. VM. {{UIMeta group=3 order=3 }}"
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

variable "create_usermanaged_notebook" {
  description = "Set to true if you want to create user managed workbench notebooks. If you want to create google managed workbench notebook, set this variable to false. {{UIMeta group=3 order=1 }}"
  type        = bool
  default     = true
}

variable "container_image_repository" {
  description = "Container Image Repo, only set if creating container image notebook instance by setting `create_container_image` variable to true. {{UIMeta group=3 order=4 }}"
  type        = string
  default     = ""
}

variable "container_image_tag" {
  description = "Container Image Tag, only set if creating container image notebook instance by setting `create_container_image` variable to true. {{UIMeta group=3 order=5 }}"
  type        = string
  default     = "latest"
}

variable "deployment_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`."
  type        = string
  default     = null
}

variable "enable_gpu_driver" {
  description = "Install GPU driver on the instance. {{UIMeta group=3 order=9 }}"
  type        = bool
  default     = false
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

variable "gpu_accelerator_type" {
  description = "Type of GPU you would like to spin up. {{UIMeta group=3 order=10 }}"
  type        = string
  default     = ""
}

variable "gpu_accelerator_core_count" {
  description = "Number of of GPU core count. {{UIMeta group=3 order=11 }}"
  type        = number
  default     = 0
}

variable "image_family" {
  description = "Image of the AI notebook. {{UIMeta group=3 order=13 }}"
  type        = string
  default     = "tf-latest-cpu"
}

variable "image_project" {
  description = "Google Cloud project where the image is hosted. {{UIMeta group=3 order=12 }}"
  type        = string
  default     = "deeplearning-platform-release"
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for AI Notebooks subnet. {{UIMeta group=2 order=5 }}"
  type        = string
  default     = "10.142.190.0/24"
}

variable "machine_type" {
  description = "Type of VM you would like to spin up. {{UIMeta group=3 order=6 }}"
  type        = string
  default     = "n1-standard-4"
}

variable "network_name" {
  description = "Name of the network to be created. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "neon-network"
}

variable "notebook_count" {
  description = "Number of Vertex AI Notebooks requested. NOTE: Reducing the notebook count will delete the notebooks and the data within the same. {{UIMeta group=3 order=2 updatesafe }}"
  type        = number
  default     = 1
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
  default     = "radlab-neon"
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
  description = "Enable org policy to allow External (Public) IP addresses on virtual machines. {{UIMeta group=0 order=16 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs. {{UIMeta group=0 order=17 updatesafe }}"
  type        = bool
  default     = false
}

variable "set_trustedimage_project_policy" {
  description = "Apply org policy to set the trusted image projects. {{UIMeta group=0 order=18 updatesafe }}"
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the Notebooks. {{UIMeta group=2 order=4 }}"
  type        = string
  default     = "neon-subnet"
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
  description = "Cloud Zone associated to the AI Notebooks. {{UIMeta group=2 order=3 options=us-central1-b,us-east1-a,us-west3-b,us-east4-c }}"
  type        = string
  default     = "us-central1-c"
}
