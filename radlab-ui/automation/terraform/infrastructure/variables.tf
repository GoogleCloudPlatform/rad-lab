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

variable "admin_group_name" {
  description = "Name of the Cloud Identity group where Admin users will be stored."
  type        = string
  default     = "rad-lab-admins"
}

variable "app_engine_location" {
  description = "The location where the App Engine project will be created."
  type        = string
  default     = "us-central"
}

variable "billing_account_id" {
  description = "Billing account that will be attached to the Google Cloud project."
  type        = string

  validation {
    condition     = var.billing_account_id == null || can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.billing_account_id))
    error_message = "The format of the billing account ID is incorrect."
  }

}

variable "bucket_admin_location" {
  description = "Location where the bucket should be stored that stores the Admin terraform state files."
  type        = string
  default     = "US"
}

variable "bucket_admin_name" {
  description = "Name of the bucket that will contain all the admin settings, incl. Terraform state, for all RAD Lab deployments."
  type        = string
  default     = "rad-lab-admin"
}

variable "bucket_admin_versioning" {
  description = "Whether or not to enable versioning on the bucket that contains the Admin settings and terraform state files."
  type        = string
  default     = true
}

variable "bucket_deployments_location" {
  description = "Location where the bucket should be stored."
  type        = string
  default     = "US"
}

variable "bucket_deployments_name" {
  description = "Name of the bucket that will contain all deployment information for all RAD Lab deployments (files, logs, status, ...)."
  type        = string
  default     = "rad-lab-deployments"
}

variable "bucket_deployments_versioning" {
  description = "Whether or not to enable versioning on the bucket that contains all the deployment files."
  type        = bool
  default     = false
}

variable "bucket_function_deployments_location" {
  description = "Location where the bucket stores it archives for deploying Cloud Functions."
  type        = string
  default     = "US"
}

variable "bucket_function_deployments_name" {
  description = "Name of the bucket that will store the Cloud Function deployment archives."
  type        = string
  default     = "rad-lab-fn-deployments"
}

variable "bucket_function_deployments_versioning" {
  description = "Whether or not to enable versioning on the bucket that contains the Cloud Function archives."
  type        = bool
  default     = true
}

variable "developers_backend_api" {
  description = "Users who require permissions to develop the Backend API.  Should include the type (user:, serviceAccount:, group:)."
  type        = set(string)
  default     = []
}

variable "developers_frontend" {
  description = "Users who require permissions to develop the Frontend.  Should include the type (user:, serviceAccount:, group:)."
  type        = set(string)
  default     = []
}

variable "developers_infrastructure" {
  description = "Users who require permissions to develop the Terraform code and update the Cloud Functions.  Should include the type (user:, serviceAccount:, group:)."
  type        = set(string)
  default     = []
}

variable "disable_require_vpc_egress_connector_org_policy" {
  description = "If a VPC Egress Connector is require according to the organization policies, the deployment will fail.  This variable allows to remove that organization policy."
  type        = bool
  default     = false
}

variable "function_delete_module_name" {
  description = "Name of the Cloud Function that will delete a RAD Lab module."
  type        = string
  default     = "cf-rl-delete-module"
}

variable "function_create_identity_name" {
  description = "Service account name of the Cloud Function that will trigger the Cloud Build pipeline to create and modify modules."
  type        = string
  default     = "cf-rl-create-identity"
}

variable "function_create_module_name" {
  description = "Name of the Cloud Function that will create and update a RAD Lab module."
  type        = string
  default     = "cf-rl-create-module"
}

variable "git_ref" {
  description = "What ref should be built by the Cloud Build trigger."
  type        = string
  default     = "refs/heads/main"
}

variable "git_repo_access_token" {
  description = "Name for the secret that will store the Personal Access Token for the UI to talk to GitHub repository."
  type        = string
  default     = "rad-lab-git-access-token"
}

variable "git_repo_url" {
  description = "URL of the repository where the module code will be stored.  Used by Cloud Build to retrieve the source code and build modules.  If you want to use the open source repository, this can be set to https://github.com/GoogleCloudPlatform/rad-lab."
  type        = string
}

variable "git_repo_type" {
  description = "What the type of repository is.  Can only contain GITHUB, CLOUD_SOURCE_REPOSITORIES or UNKNOWN."
  type        = string
  default     = "GITHUB"

  validation {
    condition     = var.git_repo_type == "GITHUB" || var.git_repo_type == "CLOUD_SOURCE_REPOSITORIES" || var.git_repo_type == "UNKNOWN"
    error_message = "Git repo type can only be set to GITHUB, CLOUD_SOURCE_REPOSITORIES or UNKNOWN."
  }
}

variable "github_api_token" {
  description = "API token so that backend can talk to the GitHub APIs"
  type        = string
  sensitive   = true
  default     = null
}

variable "module_deployment_billing_account" {
  description = "If a different billing account will be used for creating RAD Lab modules, use this variable.  Otherwise the same billing account linked to the RAD Lab UI project will be used."
  type        = string
  default     = null

  validation {
    condition     = var.module_deployment_billing_account == null || can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.module_deployment_billing_account))
    error_message = "The format of the billing account ID is incorrect."
  }
}

variable "module_deployment_folder" {
  description = "If the RAD Lab modules have to be deployed in a different folder, use this folder.  Otherwise, the modules will be deployed underneath the same parent as where the RAD Lab UI project is deployed."
  type        = string
  default     = null

  validation {
    condition     = var.module_deployment_folder == null || can(regex("^folders/[0-9]+", var.module_deployment_folder))
    error_message = "The format has to be 'folders/FOLDER_ID'."
  }
}

variable "organization_name" {
  description = "Domain of the organization where the project will be created."
  type        = string
}

variable "parent" {
  description = "Parent ID where the RAD Lab UI project should be created.  Has to be formatted as 'folders/12345678'"
  type        = string

  validation {
    condition     = var.parent == null || can(regex("^folders/[0-9]+", var.parent))
    error_message = "RAD Lab UI can only be installed with a parent folder, not directly underneath the organization node.  The format also has to be 'folders/FOLDER_ID'."
  }
}

variable "project_apis" {
  description = "List of additional project APIs that should be enabled on the project.  Will be merged with the necessary APIs, required to run everything."
  type        = list(string)
  default     = []
}

variable "project_creator_display_name" {
  description = "Description for the service account that will be responsible for creating the RAD Lab modules on the platform."
  type        = string
  default     = "RAD Lab Module Creator"
}

variable "project_creator_identity" {
  description = "Name for the service account that will be responsible for creating the RAD Lab modules on the platform."
  type        = string
  default     = "rad-lab-module-creator"
}

variable "project_name" {
  description = "Name of the project where the RAD LAB UI will be installed, and all related resources."
  type        = string
  default     = "rad-lab-ui"
}

variable "region" {
  description = "Default region for most resources."
  type        = string
  default     = "us-central1"
}

variable "set_billing_permissions" {
  description = "Whether or not grant billing permissions to the service account that creates the projects for all RAD Lab modules. In some organizations, people who will create the UI won't have the necessary permissions to manage the Billing Account as well.  If that is not the case, set this variable to true."
  type        = bool
  default     = false
}

variable "super_admins" {
  description = "Grants Owner permissions on the project.  Should only be used during the initial phase or as a break glass procedure.  Should come in the format user:, group:"
  type        = set(string)
  default     = []
}

variable "terraform_builder_checksum" {
  description = "Checksum for the Terraform binary."
  type        = string
  default     = "9fd445e7a191317dcfc99d012ab632f2cc01f12af14a44dfbaba82e0f9680365"
}

variable "terraform_builder_registry_id" {
  description = "ID for Artifact Registry, where the image for the Terraform builder will be stored."
  type        = string
  default     = "rad-lab-ui-registry"
}

variable "terraform_builder_version" {
  description = "Version of Terraform for the builder."
  type        = string
  default     = "1.2.6"
}

variable "topic_delete_name" {
  description = "Name of the Pub/Sub topic to delete module deployments"
  type        = string
  default     = "rad-lab-topic-delete"
}

variable "ui_automation_identity_id" {
  description = "Name of the service account that will be used to automate the UI."
  type        = string
  default     = "rad-lab-ui-automation"
}

variable "ui_automation_identity_name" {
  description = "Display name of the service account that is attached to the pipeline automating the UI."
  type        = string
  default     = "RAD Lab UI Automation Identity"
}

variable "user_group_name" {
  description = "Name of the group that will store the RAD Lab users."
  type        = string
  default     = "rad-lab-users"
}

variable "webapp_identity" {
  description = "Name of the identity that should be attached to the deployed app engine application."
  type        = string
  default     = "rad-lab-ui-identity"
}

variable "webapp_identity_display_name" {
  description = "Display name of the identity attached to the UI (App Engine)."
  type        = string
  default     = "RAD Lab UI Identity"
}
