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
  description = "Billing Account associated to the GCP Resources."
  type        = string
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "deployment_id" {
  description = "Add a suffix of 4 random characters to the `project_id`."
  type        = string
  default     = null

  validation {
    condition     = var.deployment_id == null || can(regex("^[a-zA-Z0-9]{4}$"))
    error_message = "Deployment ID should be 4 characters long and can only consist of lower and/or upper case characters and numbers"
  }
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Project labels to add to the project."
  type        = map(string)
  default     = {}
}

variable "lien_reason" {
  description = "Put a lien on the project."
  type        = string
  default     = null
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id."
  type        = string
  default     = ""
}

variable "organization_policies_bool" {
  description = "Map of organization policies (boolean) to apply on the project.  Status is true for allow, false for deny and null for restore."
  type        = map(bool)
  default     = {}
  nullable    = false
}

variable "organization_policies_list" {
  description = "Map of organization policies (list) to apply on the project.  Status is true for allow, false for deny and null for restore."
  type = map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  }))
  default  = {}
  nullable = false
}

variable "project_apis" {
  description = "Google APIs which have to be enabled on the project."
  type        = set(string)
  default     = []
}

variable "project_apis_config" {
  description = "Service activation configuration"
  type = object({
    disable_on_destroy         = bool
    disable_dependent_services = bool
  })
  default = {
    disable_on_destroy         = false
    disable_dependent_services = false
  }
}

variable "project_id_prefix" {
  description = "If `create_project` is true, this will be the prefix of the Project ID & name created. If `create_project` is false this will be the actual Project ID, of the existing project where you want to deploy the module."
  type        = string
}

variable "skip_delete" {
  description = "Allows the underlying resources to be destroyed without destroying the project itself."
  type        = bool
  default     = false
}