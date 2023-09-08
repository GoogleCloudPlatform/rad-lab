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
  region    = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])
  
  project = (var.create_project
    ? try(module.project_radlab_genomics.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  network = (
    var.create_network
    ? try(module.vpc_ngs.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.vpc_ngs.0.subnets["${local.region}/${var.subnet}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )
  
  ngs_sa_project_roles = [
    "roles/compute.instanceAdmin",
    "roles/storage.objectViewer",
    "roles/storage.admin",
    "roles/lifesciences.serviceAgent",
    "roles/lifesciences.workflowsRunner",
    "roles/iam.serviceAccountUser"
  ]

  default_apis = [
    "compute.googleapis.com",
    "lifesciences.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
  project_services = var.enable_services ? (var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis,["pubsub.googleapis.com"])) : local.default_apis) : []
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

#####################
# GENOMICS PROJECT #
#####################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "project_radlab_genomics" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = format("%s-%s", var.project_id_prefix, local.random_id)
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

  depends_on = [
    module.project_radlab_genomics
  ]
}

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network
}

data "google_compute_subnetwork" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.subnet
  region  = local.region
}

module "vpc_ngs" {
  count   = var.create_network ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = local.project.project_id
  network_name = var.network
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = var.subnet
      subnet_ip             = var.ip_cidr_range
      subnet_region         = local.region
      description           = "Subnetwork inside *vpc-ngs* VPC network, created via Terraform"
      subnet_private_access = true
    }
  ]
  
  depends_on = [
    module.project_radlab_genomics,
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]

}

resource "google_service_account" "sa_p_ngs" {
  project      = local.project.project_id
  account_id   = format("sa-p-ngs-%s", local.random_id)
  display_name = "NGS in trusted environment"
}

resource "google_project_iam_member" "sa_p_ngs_permissions" {
  for_each = toset(local.ngs_sa_project_roles)
  project  = local.project.project_id
  member   = "serviceAccount:${google_service_account.sa_p_ngs.email}"
  role     = each.value
}

resource "google_service_account_iam_member" "sa_ngs_iam" {
  for_each           = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  member             = each.value
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.sa_p_ngs.id
}


# Bucket to store sequence inputs and processed outputs #
resource "google_storage_bucket" "input_bucket" {
  project                     = local.project.project_id
  name                        = join("", ["ngs-input-bucket-", local.random_id])
  location                    = local.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_binding" "binding1" {
  bucket  = google_storage_bucket.input_bucket.name
  role    = "roles/storage.admin"
  members = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
}

resource "google_storage_bucket" "output_bucket" {
  project                     = local.project.project_id
  name                        = join("", ["ngs-output-bucket-", local.random_id])
  location                    = local.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_binding" "binding2" {
  bucket  = google_storage_bucket.output_bucket.name
  role    = "roles/storage.admin"
  members = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
}

# Bucket to store Cloud functions #
resource "google_storage_bucket" "source_code_bucket" {
  project                     = local.project.project_id
  name                        = join("", ["radlab-source-code-bucket-", local.random_id])
  location                    = local.region
  uniform_bucket_level_access = true
}

data "archive_file" "source_zip" {
  type        = "zip"
  output_path = "${path.module}/function-source.zip"
  source_dir  = "${path.module}/scripts/build/cloud_functions/function-source/"
}

resource "google_storage_bucket_object" "archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.source_code_bucket.name
  source = data.archive_file.source_zip.output_path
}

# Create cloud functions from source code (Zip) stored in Bucket #

resource "google_cloudfunctions_function" "function" {
  name                  = "ngs-qc-fastqc-fn"
  description           = "Cloud function that uses dsub to execute pipeline jobs using lifesciences api in GCP."
  project               = local.project.project_id
  runtime               = "python38"
  region                = local.region
  ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.source_code_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  timeout               = 60
  entry_point           = "ngs_qc_trigger"
  service_account_email = google_service_account.sa_p_ngs.email

  labels = {
    my-label = "my-label-value"
  }

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.input_bucket.name
  }

  environment_variables = {
    GCP_PROJECT       = local.project.project_id
    GCS_OUTPUT_BUCKET = join("", ["gs://", google_storage_bucket.output_bucket.name])
    GCS_LOG_LOCATION  = join("", ["gs://", google_storage_bucket.output_bucket.name, "/logs"])
    CONTAINER_IMAGE   = join("", ["gcr.io/", local.project.project_id, "/fastqc:latest"])
    REGION            = local.region
    NETWORK           = local.network.self_link
    SUBNETWORK        = local.subnet.self_link
    ZONES             = var.zone
    DISK_SIZE         = var.boot_disk_size_gb
    SERVICE_ACCOUNT   = google_service_account.sa_p_ngs.email
  }
}

# Locally build container for bioinformatics tool and push to container registry #
resource "null_resource" "build_and_push_image" {
  triggers = {
    cloudbuild_yaml_sha = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/cloudbuild.yaml"))
    dockerfile_sha      = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/Dockerfile"))
    build_script_sha    = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/build-container.sh"))
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "bash ${path.module}/scripts/build/container/fastqc-0.11.9a/build-container.sh ${local.project.project_id} ${var.resource_creator_identity}"

  }
}