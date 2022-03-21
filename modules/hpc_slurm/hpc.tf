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
  user_node_access = toset(concat(var.hpc_users, var.hpc_login_users, var.hpc_controller_users))
}

data "google_compute_image" "schedmd_slurm_img" {
  project = "schedmd-slurm-public"
  family  = "schedmd-slurm-21-08-6-debian-10"
}

resource "google_project_iam_member" "hpc_node_access" {
  for_each = local.user_node_access
  member   = "user:${each.value}"
  project  = module.hpc_slurm_project.project_id
  role     = "roles/compute.viewer"
}

resource "google_compute_instance_iam_member" "hpc_login_access" {
  for_each      = local.login_node_access_users
  project       = module.hpc_slurm_project.project_id
  instance_name = google_compute_instance.login_node.name
  member        = "user:${each.value}"
  role          = "roles/compute.osLogin"
}

resource "google_compute_instance_iam_member" "hpc_controller_access" {
  for_each      = local.controller_node_access_users
  project       = module.hpc_slurm_project.project_id
  instance_name = google_compute_instance.slurm_controller.name
  member        = "user:${each.value}"
  role          = "roles/compute.osLogin"
}
