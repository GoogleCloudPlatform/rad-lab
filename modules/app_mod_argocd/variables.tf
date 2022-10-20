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

variable "argo_cd_management_identity" {
  description = "Identity for the ArgoCD management cluster."
  type        = string
  default     = "argocd-fleet-admin"
}

variable "argo_cd_management_cluster_name" {
  description = "Name for the Argo CD management cluster."
  type        = string
  default     = "argo-cd-mgmt"
}

variable "argo_cd_management_cluster_region" {
  description = "Region where the ArgoCD should be created.  This needs to correspond to the "
  type        = string
  default     = "us-east1"
}

variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources.  {{UIMeta group=0 order=3 updatesafe }}"
  type        = string
}

variable "create_network" {
  description = "Set to true whether or not a network should be created."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "deployment_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. {{UIMeta group=0 order=2 updatesafe }}"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Name of the network.  If the resources are deployed in an existing network, this has to correspond to the correct network name"
  type        = string
  default     = "argocd-demo-nw"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id. {{UIMeta group=0 order=1 }}"
  type        = string
  default     = ""
}

variable "project_id_prefix" {
  description = "If `create_project` is true, this will be the prefix of the Project ID & name created. If `create_project` is false this will be the actual Project ID, of the existing project where you want to deploy the module. {{UIMeta group=1 order=2 }}"
  type        = string
  default     = "radlab-data-science"
}

variable "region" {
  description = "Default region where all resources will be created."
  type        = string
  default     = "us-central1"
}

variable "subnets" {
  description = "Subnets where the GKE clusters will be hosted."
  type = list(object({
    name                  = string
    cidr_range            = string
    region                = string
    description           = optional(string)
    enable_private_access = optional(bool, true)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string)
      filter_expression    = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
    }))
    secondary_ip_ranges = optional(map(string))
  }))
  default = [{
    name        = "argocd-mgmt-snw-useast1"
    cidr_range  = "10.200.0.0/22"
    region      = "us-east1"
    description = "GKE Cluster US-East 1"
    secondary_ip_ranges = {
      pod-ip-range = "10.210.0.0/16"
      svc-ip-range = "10.220.0.0/16"
    }
    }, {
    name        = "argocd-demo-snw-useast1"
    cidr_range  = "10.0.0.0/22"
    region      = "us-east1"
    description = "GKE Cluster US-East 1"
    secondary_ip_ranges = {
      pod-ip-range = "10.10.0.0/16"
      svc-ip-range = "10.20.0.0/16"
    }
    }, {
    name        = "argocd-demo-snw-uscentral1"
    cidr_range  = "10.100.0.0/22"
    region      = "us-central1"
    description = "GKE Cluster US-Central 1"
    secondary_ip_ranges = {
      pod-ip-range = "10.150.0.0/16"
      svc-ip-range = "10.160.0.0/16"
    }
  }]
}

variable "zone" {
  description = "Default zone where all zonal resources will be created."
  type        = string
  default     = "us-central1-b"
}