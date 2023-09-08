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
  random_id = var.deployment_id != null ? var.deployment_id : random_id.default.hex
  project = (var.create_project
    ? try(module.project_radlab_gen_nextflow.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  region = var.region

  network = (
    var.create_network
    ? try(module.vpc_nextflow.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.vpc_nextflow.0.subnets["${local.region}/${var.network_name}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )

  project_services = var.enable_services ? [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
    "batch.googleapis.com",
    "logging.googleapis.com",
    "lifesciences.googleapis.com"
  ] : []
}

resource "random_id" "default" {
  byte_length = 2
}

####################
# nextflow Project #
####################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "project_radlab_gen_nextflow" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name                    = format("%s-%s", var.project_id_prefix, local.random_id)
  random_project_id       = false
  folder_id               = var.folder_id
  billing_account         = var.billing_account_id
  org_id                  = var.organization_id
  default_service_account = "keep"
  labels = {
    vpc-network = var.network_name
  }

  activate_apis = []
}



resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    module.project_radlab_gen_nextflow
  ]
}

data "google_compute_default_service_account" "default" {
  project = local.project.project_id
  depends_on = [
    google_project_service.enabled_services
  ]
}

resource "google_project_iam_member" "compute_service_account_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/batch.agentReporter"
  ])
  project = local.project.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_storage_bucket" "nextflow_workflow_bucket" {
  name                        = "${local.project.project_id}-nextflow-wf-exec"
  location                    = local.region
  force_destroy               = true
  uniform_bucket_level_access = true
  project                     = local.project.project_id

  cors {
    origin          = ["http://user-scripts"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_object" "config" {
  name   = "provisioning/nextflow.config"
  bucket = google_storage_bucket.nextflow_workflow_bucket.name
  content = templatefile("scripts/build/nextflow.config", {
    NEXTFLOW_PROJECT         = local.project.project_id,
    NEXTFLOW_WORK_DIR        = "${google_storage_bucket.nextflow_workflow_bucket.url}/workdir",
    NEXTFLOW_NETWORK         = var.network_name
    NEXTFLOW_SUBNET          = var.subnet_name
    NEXTFLOW_SERVICE_ACCOUNT = module.nextflow_service_account.email,
    NEXTFLOW_LOCATION        = var.nextflow_api_location,
    NEXTFLOW_ZONE            = var.nextflow_zone
  })
}

resource "google_storage_bucket_object" "bootstrap" {
  name   = "provisioning/bootstrap.sh"
  bucket = google_storage_bucket.nextflow_workflow_bucket.name
  content = templatefile("scripts/build/bootstrap.sh", {
    BUCKET_URL = google_storage_bucket.nextflow_workflow_bucket.url
  })
}
