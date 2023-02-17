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

locals {
  random_id   = var.random_id == null ? random_id.randomizer.hex : var.random_id
  project_id  = var.create_project ? format("%s-%s", var.project_name, local.random_id) : var.project_name
  parent_type = var.parent == null ? null : split("/", var.parent)[0]
  parent_id   = var.parent == null ? null : split("/", var.parent)[1]

  project = (
    var.create_project ?
    {
      project_id = try(google_project.project.0.project_id, null)
      number     = try(google_project.project.0.number, null)
      name       = try(google_project.project.0.name, null)
    }
    : {
      project_id = local.project_id
      number     = try(data.google_project.existing_project.0.number, null)
      name       = try(data.google_project.existing_project.0.name, null)
    }
  )
}

resource "random_id" "randomizer" {
  byte_length = 2
}

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = local.project_id
}

resource "google_project" "project" {
  count               = var.create_project ? 1 : 0
  org_id              = local.parent_type == "organizations" ? local.parent_id : null
  folder_id           = local.parent_type == "folders" ? local.parent_id : null
  name                = local.project_id
  project_id          = local.project_id
  billing_account     = var.billing_account_id
  auto_create_network = var.auto_create_network
  labels              = var.labels
  skip_delete         = var.skip_delete
}

resource "google_project_service" "project_services" {
  for_each                   = var.project_apis
  project                    = local.project.project_id
  service                    = each.value
  disable_on_destroy         = var.service_config.disable_on_destroy
  disable_dependent_services = var.service_config.disable_dependent_services
}

resource "google_resource_manager_lien" "lien" {
  count        = var.lien_reason != "" ? 1 : 0
  parent       = "projects/${local.project.number}"
  origin       = "created-by-terraform"
  reason       = var.lien_reason
  restrictions = ["resourcemanager.projects.delete"]
}
