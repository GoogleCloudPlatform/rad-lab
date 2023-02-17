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
  description = "Billing account ID that will be linked to the project. {{UIMeta group=0 order=3 updatesafe }}"
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
  description = "Indicate if the deployment has to use a network that already exists. {{UIMeta group=2 order=1 }}"
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Create a new project or use an existing project.  When set to true, variable project_name has to match the exact project ID of the existing project. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "deploy_elastic_search" {
  description = "Deploy Elastic Search and Kibana. {{UIMeta group=4 order=1 }}"
  type        = bool
  default     = true
}

variable "deployment_id" {
  description = "Random ID that will be used to suffix all resources.  Leave blank if you want the module to use a generated one."
  type        = string
  default     = null
}

variable "disk_size_gb_nodes" {
  description = "Size of the disks attached to the nodes. {{UIMeta group=3 order=10 }}"
  type        = number
  default     = 256
}

variable "disk_type_nodes" {
  description = "Type of disks to attach to the nodes. {{UIMeta group=3 order=9 }}"
  type        = string
  default     = "pd-standard"
}

variable "elastic_search_instance_count" {
  description = "Number of instances of the Elastic Search pod. {{UIMeta group=4 order=3 updatesafe }}"
  type        = string
  default     = "1"
}

variable "elk_version" {
  description = "Version for Elastic Search and Kibana. {{UIMeta group=4 order=4 }}"
  type        = string
  default     = "7.15.1"
}

variable "enable_internet_egress_traffic" {
  description = "Enable egress traffic to the internet.  Necessary to download the Elastic Search pods. {{UIMeta group=3 order=16 }}"
  type        = bool
  default     = true
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

variable "gke_cluster_name" {
  description = "Name that will be assigned to the GKE cluster. {{UIMeta group=3 order=1 }}"
  type        = string
  default     = "elastic-search-cluster"
}

variable "gke_version" {
  description = "Version to be used for the GKE cluster.  Ensure that the release channel is properly set when updating this variable. {{UIMeta group=3 order=2 }}"
  type        = string
  default     = "1.20.10-gke.1600"
}

variable "kibana_instance_count" {
  description = "Number of Kibana instances deployed in the cluster. {{UIMeta group=4 order=2 updatesafe }}"
  type        = string
  default     = "1"
}


variable "master_ipv4_cidr_block" {
  description = "IPv4 CIDR block to assign to the Master cluster. {{UIMeta group=3 order=11 }}"
  type        = string
  default     = "10.200.0.0/28"
}

variable "network_cidr_block" {
  description = "CIDR block to be assigned to the network. {{UIMeta group=2 order=5 }}"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_name" {
  description = "Name to be assigned to the network hosting the GKE cluster. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "elastic-search-nw"
}

variable "node_pool_machine_type" {
  description = "Machine type for the node pool. {{UIMeta group=3 order=6 }}"
  type        = string
  default     = "e2-medium"
}

variable "node_pool_max_count" {
  description = "Maximum instance count for the custom node pool. {{UIMeta group=3 order=7 updatesafe }}"
  type        = number
  default     = 10
}

variable "node_pool_min_count" {
  description = "Minimum instance count for the custom nodepool. {{UIMeta group=3 order=8 updatesafe }}"
  type        = number
  default     = 1
}

variable "node_pool_name" {
  description = "Name of the nodepool. {{UIMeta group=3 order=5 }}"
  type        = string
  default     = "elastic-search-pool"
}

variable "organization_id" {
  description = "Organization ID where the project will be created. It can be skipped if already setting folder_id. {{UIMeta group=0 order=1 }}"
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

variable "pod_cidr_block" {
  description = "CIDR block to be assigned to pods running in the GKE cluster. {{UIMeta group=3 order=13 }}"
  type        = string
  default     = "10.100.0.0/16"
}

variable "pod_ip_range_name" {
  description = "Range name for the pod IP addresses. {{UIMeta group=3 order=12 }}"
  type        = string
  default     = "pod-ip-range"
}

variable "preemptible_nodes" {
  description = "Use preemptible VMs for the node pools. {{UIMeta group=3 order=4 }}"
  type        = bool
  default     = true
}

variable "project_id_prefix" {
  description = "If `create_project` is true, this will be the prefix of the Project ID & name created. If `create_project` is false this will be the actual Project ID, of the existing project where you want to deploy the module. {{UIMeta group=1 order=2 }}"
  type        = string
  default     = "radlab-app-mod-elastic"
}

variable "region" {
  description = "Region where the resources should be created. {{UIMeta group=2 order=3 }}"
  type        = string
  default     = "us-west1"
}

variable "release_channel" {
  description = "Enroll the GKE cluster in this release channel. {{UIMeta group=3 order=3 }}"
  type        = string
  default     = "REGULAR"
}

variable "resource_creator_identity" {
  description = "Terraform Service Account which will be creating the GCP resources. If not set, it will use user credentials spinning up the module. {{UIMeta group=0 order=4 updatesafe }}"
  type        = string
  default     = ""
}

variable "service_cidr_block" {
  description = "CIDR block to be assigned to services running in the GKE cluster. {{UIMeta group=3 order=15 }}"
  type        = string
  default     = "10.150.0.0/16"
}

variable "service_ip_range_name" {
  description = "Name for the IP range for services. {{UIMeta group=3 order=14 }}"
  type        = string
  default     = "service-ip-range"
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

variable "set_vpc_peering_policy" {
  description = "Enable org policy to VPC Peering. {{UIMeta group=0 order=17 updatesafe }}"
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "Name to be assigned to the subnet hosting the GKE cluster. {{UIMeta group=2 order=4 }}"
  type        = string
  default     = "elastic-search-snw"
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