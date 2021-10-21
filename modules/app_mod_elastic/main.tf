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

locals {
  random_id          = var.random_id != null ? var.random_id : random_id.random_id.hex
  project_name       = format("%s-%s", var.project_name, local.random_id)
  pod_range_name     = "pod-ip-range"
  service_range_name = "service-ip-range"
}

resource "random_id" "random_id" {
  byte_length = 2
}

module "elastic_search_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = local.project_name
  random_project_id = false
  org_id            = var.organization_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}
