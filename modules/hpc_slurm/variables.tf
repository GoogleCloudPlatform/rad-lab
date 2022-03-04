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

variable "billing_account_id" {
  description = "Billing Account ID to be assigned to the project."
  type        = string
}

variable "create_network" {
  description = "Whether or not to create a network or use an existing one."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Whether or not to create a project or use an existing one."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to be assigned to the resources."
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "Name for the network where HPC resources will be deployed."
  type        = string
  default     = "rad-hpc-slurm-nw"
}

variable "parent" {
  description = "Organization or Folder ID where the project should be created.  Has to be in the form organizations/XYZ or folders/XYZ."
  type        = string
  default     = null
}


variable "project_id" {
  description = "Project ID to be assigned to the project.  If a value is provided, it should correspond to an existing Project ID, as RAD Lab will try to deploy the resources in that project."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name to be used for the project."
  type        = string
  default     = "rad-hpc-slurm"
}

variable "random_id" {
  description = "Random ID to add to resources."
  type        = string
  default     = null
}

variable "region" {
  description = "Default region to use for all resources, apart from subnets."
  type        = string
  default     = "us-central1"
}

variable "slurm_controller_cluster_name" {
  description = "Name to be used for the cluster."
  type        = string
  default     = "rad-hpc-slurm-controller"
}

variable "slurm_controller_partitions" {
  description = "A list of partitions for the Controller cluster."
  type = list(object({
    name                 = string,
    machine_type         = string,
    max_node_count       = number,
    zone                 = string,
    image                = string,
    image_hyperthreads   = bool,
    compute_disk_type    = string,
    compute_disk_size_gb = number,
    compute_labels       = any,
    cpu_platform         = string,
    gpu_type             = string,
    gpu_count            = number,
    network_storage = list(object({
      server_ip    = string,
      remote_mount = string,
      local_mount  = string,
      fs_type      = string,
    mount_options = string })),
    preemptible_bursting = string,
    vpc_subnet           = string,
    exclusive            = bool,
    enable_placement     = bool,
    regional_capacity    = bool,
    regional_policy      = any,
    instance_template    = string,
    static_node_count    = number
  }))
  default = [{
    name                 = "radlab-controller-partition"
    image                = "projects/schedmd-slurm-public/global/images/family/schedmd-slurm-21-08-4-hpc-centos-7"
    machine_type         = "c2-standard-4"
    static_node_count    = 0
    max_node_count       = 10
    zone                 = "us-central1-a"
    image_hyperthreads   = true
    compute_disk_type    = "pd-standard"
    compute_disk_size_gb = 20
    compute_labels       = {}
    cpu_platform         = null
    gpu_count            = 0
    gpu_type             = null
    network_storage      = []
    preemptible_bursting = false
    vpc_subnet           = null
    exclusive            = false
    enable_placement     = false
    regional_capacity    = false
    regional_policy      = {}
    instance_template    = null
  }]
}

variable "subnets" {
  description = "List of subnets to create on the network."
  type = list(object({
    name               = string
    cidr_range         = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = [{
    name               = "rad-hpc-slurm-snw-use1"
    cidr_range         = "10.0.0.0/16"
    region             = "us-east1"
    secondary_ip_range = null
  }]
}

