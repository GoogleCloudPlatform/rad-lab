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
  iam_members = flatten([
    for member, roles in var.iam_members : [
      for role in roles : {
        role   = role
        member = member
      }
    ]
  ])
}

resource "google_project_iam_member" "additive_iam_permissions" {
  for_each = {
    for permission in local.iam_members: "${permission.role}${permission.member}" => permission
  }

  member  = each.value.member
  project = local.project.project_id
  role    = each.value.role
}