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


provider "google" {
  alias        = "impersonated"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonated
  scopes                 = ["userinfo-email", "cloud-platform"]
  target_service_account = var.resource_creator_identity
  lifetime               = "1800s"
}

provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
}

provider "google-beta" {
  access_token = data.google_service_account_access_token.default.access_token
}


locals {
  random_id = var.random_id != null ? var.random_id : random_id.default.hex
  project = (var.create_project
    ? try(module.project_radlab_billing_budget.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  project_services = var.enable_services ? var.apis : []
}

resource "random_id" "default" {
  byte_length = 2
}

###############
# GCP PROJECT #
###############

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_name
}

module "project_radlab_billing_budget" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = format("%s-%s", var.project_name, local.random_id)
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id

  activate_apis = []
}


resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "time_sleep" "wait_120_seconds" {
  count = var.enable_services ? 1 : 0
  create_duration = "120s"

  depends_on = [
    google_project_service.enabled_services
  ]
}

module "billing_budget" {
  source                  = "terraform-google-modules/project-factory/google//modules/budget"
  display_name            = format("RADLab Billing Budget - %s", local.project.project_id)
  billing_account         = var.billing_account_id
  projects                = ["${local.project.project_id}"]
  amount                  = var.billing_budget_amount
  alert_spend_basis       = var.billing_budget_alert_spend_basis
  alert_spent_percents    = var.billing_budget_alert_spent_percents
  credit_types_treatment  = var.billing_budget_credit_types_treatment
  labels                  = var.billing_budget_labels
  services                = var.billing_budget_services

  depends_on = [
    time_sleep.wait_120_seconds
  ]

}

resource "google_project_iam_member" "user_role_assignment" {
  for_each = var.trusted_users
  project  = local.project.project_id
  member   = each.value
  role     = "roles/editor"
}