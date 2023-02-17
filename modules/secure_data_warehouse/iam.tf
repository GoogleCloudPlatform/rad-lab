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

resource "google_project_iam_member" "role_viewer_sdw_data_ingest" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_ingest.project_id
  role     = "roles/viewer"
}

resource "google_project_iam_member" "role_viewer_sdw_data_govern" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_govern.project_id
  role     = "roles/viewer"
}

resource "google_project_iam_member" "role_viewer_sdw_non_conf_data" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_non_conf_data.project_id
  role     = "roles/viewer"
}

resource "google_project_iam_member" "role_viewer_sdw_conf_data" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_conf_data.project_id
  role     = "roles/viewer"
}

resource "google_project_iam_member" "role_viewer_template" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member   = each.value
  project  = module.template_project.project_id
  role     = "roles/viewer"
}

#########################################################################
# IAM - Owner User/Group
#########################################################################

/*
  Allows the user to add ownership for other users or groups.  Be very careful when granting these access rights,
  as they have gain full ownership of the projects and can potentially break the entire module.

  More information: https://cloud.google.com/iam/docs/understanding-roles#basic
*/

resource "google_project_iam_member" "role_owner_sdw_data_ingest" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_ingest.project_id
  role     = "roles/owner"
}

resource "google_project_iam_member" "role_owner_sdw_data_govern" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_govern.project_id
  role     = "roles/owner"
}

resource "google_project_iam_member" "role_owner_sdw_non_conf_data" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_non_conf_data.project_id
  role     = "roles/owner"
}

resource "google_project_iam_member" "role_owner_sdw_conf_data" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_conf_data.project_id
  role     = "roles/owner"
}

resource "google_project_iam_member" "role_owner_template" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.template_project.project_id
  role     = "roles/owner"
}
