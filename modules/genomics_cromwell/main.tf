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
  random_id = var.deployment_id != null ? var.deployment_id : random_id.default.0.hex
  project = (var.create_project
    ? try(module.project_radlab_gen_cromwell.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  region = var.region

  network = (
    var.create_network
    ? try(module.vpc_cromwell.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.vpc_cromwell.0.subnets["${local.region}/${var.network_name}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )

  default_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "lifesciences.googleapis.com"
  ]
  project_services = var.enable_services ? (var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis, ["pubsub.googleapis.com"])) : local.default_apis) : []
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

####################
# Cromwell Project #
####################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "project_radlab_gen_cromwell" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = format("%s-%s", var.project_id_prefix, local.random_id)
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
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
    module.project_radlab_gen_cromwell
  ]
}

resource "google_storage_bucket" "cromwell_workflow_bucket" {
  name                        = "${local.project.project_id}-cromwell-wf-exec"
  location                    = var.region
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
  name   = "provisioning/cromwell.conf"
  bucket = google_storage_bucket.cromwell_workflow_bucket.name
  content = templatefile("scripts/build/cromwell.conf", {
    CROMWELL_PROJECT         = local.project.project_id,
    CROMWELL_ROOT_BUCKET     = google_storage_bucket.cromwell_workflow_bucket.url,
    CROMWELL_VPC             = var.network_name
    CROMWELL_SERVICE_ACCOUNT = module.cromwell_service_account.email,
    CROMWELL_PAPI_LOCATION   = var.cromwell_PAPI_location,
    CROMWELL_PAPI_ENDPOINT   = var.cromwell_PAPI_endpoint,
    REQUESTER_PAY_PROJECT    = local.project.project_id,
    CROMWELL_ZONES           = "[${join(", ", var.cromwell_zones)}]"
    CROMWELL_PORT            = var.cromwell_port,
    CROMWELL_DB_IP           = module.cromwell_mysql_db.instance_ip_address[0].ip_address,
    CROMWELL_DB_PASS         = random_password.cromwell_db_pass.result
  })
}

resource "google_storage_bucket_object" "bootstrap" {
  name   = "provisioning/bootstrap.sh"
  bucket = google_storage_bucket.cromwell_workflow_bucket.name
  content = templatefile("scripts/build/bootstrap.sh", {
    CROMWELL_VERSION = var.cromwell_version,
    BUCKET_URL       = google_storage_bucket.cromwell_workflow_bucket.url
  })
}
resource "google_storage_bucket_object" "service" {
  name   = "provisioning/cromwell.service"
  source = "scripts/build/cromwell.service"
  bucket = google_storage_bucket.cromwell_workflow_bucket.name
}