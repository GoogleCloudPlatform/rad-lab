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

#########################################################################
# IAM - Trusted User/Group
#########################################################################

resource "google_project_iam_member" "role_viewer" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/viewer"
}

resource "google_project_iam_member" "role_compute_instance_admin" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/compute.instanceAdmin.v1"
}

resource "google_project_iam_member" "role_iap_tunnel_resource_accessor" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/iap.tunnelResourceAccessor"
}

resource "google_project_iam_member" "role_service_account_user" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/iam.serviceAccountUser"
}

#########################################################################
# IAM - Owner User/Group
#########################################################################

/*
  Allows the user to add ownership for other users or groups.  Be very careful when granting these access rights,
  as they have gain full ownership of the projects and can potentially break the entire module.

  More information: https://cloud.google.com/iam/docs/understanding-roles#basic
*/

resource "google_project_iam_member" "role_owner" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = local.project.project_id
  role     = "roles/owner"
}
