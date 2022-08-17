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


#########################################################################
# IAM - Trusted User/Group
#########################################################################

resource "google_project_iam_member" "trusted_user_group_role1" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/iap.tunnelResourceAccessor"
}

resource "google_project_iam_member" "trusted_user_group_role2" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/compute.instanceAdmin.v1"
}

resource "google_project_iam_member" "trusted_user_group_role3" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/viewer"
}

resource "google_project_iam_member" "sa_p_cloud_sql_permissions" {
  project  = local.project.project_id
  role     = "roles/cloudsql.client"
  member   = format("serviceAccount:%s@%s.iam.gserviceaccount.com", google_service_account.sa_p_cloud_sql.account_id,local.project.project_id)
}