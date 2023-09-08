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

variable "auto_create_network" {
  description = "Whether to create the default network for the project."
  type        = bool
  default     = false
}

variable "billing_account_id" {
  description = "Billing account to be associated to the project."
  type        = string
  default     = null
}

variable "create_project" {
  description = "Indicate whether or not a project should be created."
  type        = bool
  default     = true
}

variable "iam_members" {
  description = "IAM members and their respective roles.  Should be provided as { MEMBER => [ROLES]}.  MEMBERS has to provided as type:name (serviceAccount:, user: and/or group:)."
  type        = map(list(string))
  default     = {}
}
variable "labels" {
  description = "Labels to assign to the project."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "lien_reason" {
  description = "Provide a reason why the project should be protected from accidental deletion."
  type        = string
  default     = ""
}

variable "org_policy_bool" {
  description = "Map of organizaton policies (boolean) to apply on the project.  Set value for null to restore the original policy."
  type        = map(bool)
  default     = {}
  nullable    = false
}

variable "org_policy_list" {
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

variable "parent" {
  description = "Parent folder or organization, has to be set to either 'folders/folder_id' or 'organizations/org_id'."
  type        = string
  default     = null
  validation {
    condition     = var.parent == null || can(regex("(organizations|folders)/[0-9]+", var.parent))
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "project_apis" {
  description = "Set of APIs to enable on the project."
  type        = set(string)
  default     = null
}

variable "project_name" {
  description = "Name for the project to be created.  When an existing project should be used, the value for this variable has to be the project ID."
  type        = string
}

variable "random_id" {
  description = "Random ID that will be added to the project ID.  If the value is 'null', a random one will be generated here."
  type        = string
  default     = null
}

variable "service_config" {
  description = "Google API behaviour when deleting services."
  type = object({
    disable_on_destroy         = bool
    disable_dependent_services = bool
  })
  default = {
    disable_on_destroy         = true
    disable_dependent_services = true
  }
}

variable "skip_delete" {
  description = "Allows the underlying resources to be destroyed without destroying the project itself."
  type        = bool
  default     = false
}





