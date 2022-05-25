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

variable "create_network" {
  description = "Indicate if the deployment has to use a network that already exists."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Create a new project or use an existing project.  When set to true, variable project_name has to match the exact project ID of the existing project."
  type        = bool
  default     = true
}

variable "deploy_elastic_search" {
  description = "Deploy Elastic Search and Kibana."
  type        = bool
  default     = true
}

variable "disk_size_gb_nodes" {
  description = "Size of the disks attached to the nodes."
  type        = number
  default     = 256
}

variable "disk_type_nodes" {
  description = "Type of disks to attach to the nodes."
  type        = string
  default     = "pd-standard"
}

variable "elastic_search_instance_count" {
  description = "Number of instances of the Elastic Search pod."
  type        = string
  default     = "1"
}

variable "elk_version" {
  description = "Version for Elastic Search and Kibana."
  type        = string
  default     = "7.15.1"
}

variable "enable_apis" {
  description = "Enable APIs on the project.  When deploying in an existing project, these might already have been enabled, in which case this should be set to false."
  type        = bool
  default     = true
}

variable "enable_internet_egress_traffic" {
  description = "Enable egress traffic to the internet.  Necessary to download the Elastic Search pods."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. "
  type        = string
  default     = null
}

variable "gke_cluster_name" {
  description = "Name that will be assigned to the GKE cluster."
  type        = string
  default     = "elastic-search-cluster"
}

variable "gke_version" {
  description = "Version to be used for the GKE cluster.  Ensure that the release channel is properly set when updating this variable."
  type        = string
  default     = "1.20.10-gke.1600"
}

variable "kibana_instance_count" {
  description = "Number of Kibana instances deployed in the cluster."
  type        = string
  default     = "1"
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

variable "node_pool_max_count" {
  description = "Maximum instance count for the custom node pool."
  type        = number
  default     = 10
}

variable "node_pool_min_count" {
  description = "Minimum instance count for the custom nodepool."
  type        = number
  default     = 1
}

variable "node_pool_name" {
  description = "Name of the nodepool."
  type        = string
  default     = "elastic-search-pool"
}

variable "organization_id" {
  description = "Organization ID where the project will be created. It can be skipped if already setting folder_id"
  type        = string
  default     = null
}

variable "pod_cidr_block" {
  description = "CIDR block to be assigned to pods running in the GKE cluster."
  type        = string
  default     = "10.100.0.0/16"
}

variable "pod_ip_range_name" {
  description = "Range name for the pod IP addresses."
  type        = string
  default     = "pod-ip-range"
}

variable "preemptible_nodes" {
  description = "Use preemptible VMs for the node pools"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Name that will be assigned to the project.  To ensure uniqueness, a random_id will be added to the name."
  type        = string
  default     = "radlab-app-mod-elastic"
}

variable "random_id" {
  description = "Random ID that will be used to suffix all resources.  Leave blank if you want the module to use a generated one."
  type        = string
  default     = null
}

variable "region" {
  description = "Region where the resources should be created."
  type        = string
  default     = "us-west1"
}

variable "release_channel" {
  description = "Enroll the GKE cluster in this release channel."
  type        = string
  default     = "REGULAR"
}

variable "service_cidr_block" {
  description = "CIDR block to be assigned to services running in the GKE cluster."
  type        = string
  default     = "10.150.0.0/16"
}

variable "service_ip_range_name" {
  description = "Name for the IP range for services."
  type        = string
  default     = "service-ip-range"
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs."
  type        = bool
  default     = true
}

variable "set_vpc_peering_policy" {
  description = "Enable org policy to VPC Peering"
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name to be assigned to the subnet hosting the GKE cluster."
  type        = string
  default     = "elastic-search-snw"
}
