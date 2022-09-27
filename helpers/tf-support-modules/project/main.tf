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

locals {
  random_id   = var.deployment_id == null ? random_id.default.0.hex : var.deployment_id
  labels      = merge({ "purpose" = "radlab", "managedby" = "terraform" }, var.labels)
  parent      = length(var.folder_id) != 0 ? "folders/${var.folder_id}" : "organizations/${var.organization_id}"
  parent_type = length(var.folder_id) != 0 ? "FOLDER" : "ORGANIZATION"

  project = (
    var.create_project ?
    {
      project_id = try(google_project.default.0.project_id, null)
      name       = try(google_project.default.0.name, null)
      number     = try(google_project.default.0.number, null)
      } : {
      project_id = try(data.google_project.existing_project.0.project_id, null)
      name       = try(data.google_project.existing_project.0.name, null)
      number     = try(data.google_project.existing_project.0.number, null)
    }
  )
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

resource "google_project" "default" {
  count               = var.create_project ? 1 : 0
  name                = format("%s-%s", var.project_id_prefix, local.random_id)
  project_id          = format("%s-%s", var.project_id_prefix, local.random_id)
  billing_account     = var.billing_account_id
  auto_create_network = false
  labels              = local.labels
  skip_delete         = var.skip_delete
  folder_id           = local.parent_type == "FOLDER" ? local.parent : null
  org_id              = local.parent_type == "ORGANIZATION" ? local.parent : null
}

resource "google_project_service" "project_apis" {
  for_each                   = var.project_apis
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = var.project_apis_config.disable_dependent_services
  disable_on_destroy         = var.project_apis_config.disable_on_destroy
}

resource "google_resource_manager_lien" "lien" {
  count        = var.lien_reason != null ? 1 : 0
  origin       = "created-by-terraform"
  parent       = "projects/${local.project.number}"
  reason       = var.lien_reason
  restrictions = ["resourcemanager.projects.delete"]
}