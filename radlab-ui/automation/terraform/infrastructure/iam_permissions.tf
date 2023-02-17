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

  super_admin_project_roles = [
    "roles/owner",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator"
  ]

  developers_infrastructure_roles = [
    "roles/pubsub.editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/cloudbuild.builds.editor",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  developers_frontend_roles = [
    "roles/appengine.appAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin",
    "roles/cloudbuild.builds.editor",
    "roles/logging.viewer",
    "roles/pubsub.publisher",
    "roles/cloudfunctions.invoker",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/firebase.developAdmin"
  ]

  developers_backend_api_roles = concat(local.developers_frontend_roles, [
    "roles/pubsub.editor",
    "roles/cloudfunctions.developer",
    "roles/secretmanager.admin"
  ])

  developers_frontend_permissions = flatten([
    for user in var.developers_frontend : [
      for role in local.developers_frontend_roles : {
        user = user
        role = role
      }
    ]
  ])

  developers_backend_api_permissions = flatten([
    for user in var.developers_backend_api : [
      for role in local.developers_backend_api_roles : {
        user = user
        role = role
      }
    ]
  ])

  developers_infrastructure_permissions = flatten([
    for user in var.developers_infrastructure : [
      for role in local.developers_infrastructure_roles : {
        user = user
        role = role
      }
    ]
  ])

  super_admin_permissions = flatten([
    for user in var.super_admins : [
      for role in local.super_admin_project_roles : {
        user = user
        role = role
      }
    ]
  ])

  ui_identity_permissions = flatten([
    for user in setunion(var.developers_backend_api, var.developers_frontend) : [
      for role in [
        "roles/iam.serviceAccountUser", "roles/iam.serviceAccountTokenCreator"
        ] : {
        user = user
        role = role
      }
    ]
  ])
}

resource "google_project_iam_member" "developers_infrastructure_permissions" {
  for_each = {
    for permission in local.developers_infrastructure_permissions : "${permission.user}.${permission.role}" => permission
  }

  project = module.project.project_id
  member  = each.value.user
  role    = each.value.role
}

resource "google_project_iam_member" "developers_frontend_permissions" {
  for_each = {
    for permission in local.developers_frontend_permissions : "${permission.user}.${permission.role}" => permission
  }

  project = module.project.project_id
  member  = each.value.user
  role    = each.value.role
}

resource "google_project_iam_member" "developers_api_permissions" {
  for_each = {
    for permission in local.developers_backend_api_permissions : "${permission.user}.${permission.role}" => permission
  }

  project = module.project.project_id
  member  = each.value.user
  role    = each.value.role
}

resource "google_project_iam_member" "super_admin_permissions" {
  for_each = {
    for permission in local.super_admin_permissions : "${permission.user}.${permission.role}" => permission
  }
  member  = each.value.user
  project = module.project.project_id
  role    = each.value.role
}

resource "google_billing_account_iam_member" "super_admin_billing_permissions" {
  for_each           = var.set_billing_permissions ? var.super_admins : []
  member             = each.value
  billing_account_id = var.billing_account_id
  role               = "roles/billing.admin"
}

resource "google_service_account_iam_member" "ui_developer_access" {
  for_each = {
    for permission in local.ui_identity_permissions : "${permission.user}.${permission.role}" => permission
  }

  member             = each.value.user
  role               = each.value.role
  service_account_id = google_service_account.radlab_ui_webapp_identity.id
}

resource "google_secret_manager_secret_iam_member" "ui_developer_access" {
  for_each  = var.developers_frontend
  member    = each.value
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.git_repo_access_token.id
}
