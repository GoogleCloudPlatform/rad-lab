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
  runtime_scripts = {
    "resume.py"  = "${path.module}/scripts/usage/resume.py"
    "suspend.py" = "${path.module}/scripts/usage/suspend.py"
  }
}

resource "google_storage_bucket" "config_files" {
  project                     = local.project.project_id
  location                    = var.region
  name                        = format("%s-%s", var.hpc_config_bucket_name, local.random_id)
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "slurm_configuration" {
  bucket = google_storage_bucket.config_files.name
  name   = "slurm.conf"

  content = templatefile("${path.module}/templates/slurm.conf.tpl", {
    CONTROLLER_HOST_NAME = local.controller_host_name
    MPI_DEFAULT          = var.hpc_vars_mpi_default
    STATE_SAVE_LOCATION  = var.hpc_vars_state_save
    COMPLETE_WAIT_TIME   = var.hpc_vars_complete_wait_time
    CLUSTER_NAME         = var.hpc_cluster_name
    LOG_DIRECTORY        = var.hpc_vars_log_directory
    SCRIPT_DIRECTORY     = var.hpc_vars_script_directory
    SUSPEND_TIMEOUT      = var.hpc_vars_suspend_timeout
    RESUME_TIMEOUT       = var.hpc_vars_resume_timeout
  })
}

resource "google_storage_bucket_object" "slurm_db_configuration" {
  bucket = google_storage_bucket.config_files.name
  name   = "slurmdbd.conf"

  content = templatefile("${path.module}/templates/slurmdbd.conf.tpl", {
    STATE_SAVE_LOCATION  = var.hpc_vars_state_save
    CONTROLLER_HOST_NAME = local.controller_host_name
    SLURM_DB_NAME        = var.hpc_vars_db_name
    SLURM_DB_HOST        = module.private_sql_db_instance.private_ip_address
    SLURM_DB_PORT        = var.hpc_vars_db_port
    SLURM_DB_USER        = var.hpc_vars_db_user
    SLURM_DB_PASSWORD    = random_password.db_password.result
    LOG_DIRECTORY        = var.hpc_vars_log_directory
  })
}

resource "google_storage_bucket_object" "cgroup_configuration" {
  bucket  = google_storage_bucket.config_files.name
  name    = "cgroup.conf"
  content = templatefile("${path.module}/templates/cgroup.conf.tpl", {})
}

resource "google_storage_bucket_object" "runtime_scripts" {
  for_each = local.runtime_scripts
  bucket   = google_storage_bucket.config_files.name
  name     = each.key
  content  = file(each.value)
}