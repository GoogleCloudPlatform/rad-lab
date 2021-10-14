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
  description = "Billing account ID that will be linked to the project."
  type        = string
}

variable "folder_id" {
  description = "Folder ID where the project should be created.  Leave blank if the project should be created directly underneath the Organization node."
  type        = string
  default     = ""
}

variable "gke_cluster_name" {
  description = "Name that will be assigned to the GKE cluster."
  type        = string
  default     = "elastic-search-cluster"
}

variable "master_ipv4_cidr_block" {
  description = "IPv4 CIDR block to assign to the Master cluster."
  type        = string
  default     = "10.200.0.0/28"
}

variable "network_cidr_block" {
  description = "CIDR block to be assigned to the network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_name" {
  description = "Name to be assigned to the network hosting the GKE cluster."
  type        = string
  default     = "elastic-search-nw"
}

variable "node_pool_machine_type" {
  description = "Machine type for the node pool."
  type        = string
  default     = "e2-medium"
}

variable "node_pool_name" {
  description = "Name of the nodepool."
  type        = string
  default     = "elastic-search-pool"
}

variable "organization_id" {
  description = "Organization ID where the project will be created."
  type        = string
}

variable "pod_cidr_block" {
  description = "CIDR block to be assigned to pods running in the GKE cluster."
  type        = string
  default     = "10.100.0.0/16"
}

variable "project_name" {
  description = "Name that will be assigned to the project.  To ensure uniqueness, a random_id will be added to the name."
  type        = string
  default     = "elastic-search-demo"
}

variable "random_id" {
  description = "Random ID that will be used to suffix all resources.  Leave blank if you want to module to use a generated one."
  type        = string
  default     = null
}

variable "region" {
  description = "Region where the resources should be created."
  type        = string
  default     = "us-west1"
}

variable "service_cidr_block" {
  description = "CIDR block to be assigned to services running in the GKE cluster."
  type        = string
  default     = "10.150.0.0/16"
}

variable "subnet_name" {
  description = "Name to be assigned to the subnet hosting the GKE cluster."
  type        = string
  default     = "elastic-search-snw"
}