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
  parent_type  = var.parent == null ? null : split("/", var.parent)[0]
  parent_id    = var.parent == null ? null : split("/", var.parent)[1]
  project_name = var.project_name == null ? local.project_id : var.project_name
  random_id    = var.random_id == null ? var.random_id : var.random_id
  project_id   = var.project_id == null ? format("%s-%s", var.project_name, local.random_id) : var.project_id
  labels       = merge({ solution = "radlab", source = "terraform" }, var.labels)

  project = (
    var.create_project ?
    {
      project_id     = try(google_project.default.0.project_id, null)
      project_number = try(google_project.default.0.number, null)
      project_name   = try(google_project.default.0.name, null)
    }
    : {
      project_id     = try(data.google_project.default.0.project_id, null)
      project_number = try(data.google_project.default.0.number, null)
      project_name   = try(data.google_project.default.0.name, null)
    }
  )
}

data "google_project" "default" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id
}

resource "google_project" "default" {
  count               = var.create_project ? 1 : 0
  name                = local.project_name
  project_id          = local.project_id
  org_id              = local.parent_type == "organization" ? local.parent_id : null
  folder_id           = local.parent_type == "folders" ? local.parent_id : null
  billing_account     = var.billing_account_id
  auto_create_network = false
  labels              = var.labels
}

resource "google_project_service" "default" {
  for_each                   = var.project_services
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}