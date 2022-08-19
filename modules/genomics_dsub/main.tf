/**
 * Copyright 2021 Google LLC
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
  random_id                  = var.random_id != null ? var.random_id : random_id.random_id.hex
  radlab_genomics_project_id = var.use_random_id ? format("%s-%s", var.project_name, local.random_id) : var.project_name
  region                     = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

  ngs_sa_project_roles = [
    "roles/compute.instanceAdmin",
    "roles/storage.objectViewer",
    "roles/storage.admin",
    "roles/lifesciences.serviceAgent",
    "roles/lifesciences.workflowsRunner",
    "roles/iam.serviceAccountUser"
  ]

}

resource "random_id" "random_id" {
  byte_length = 2
}

#####################
# GENOMICS PROJECT #
#####################

module "project_radlab_genomics" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = local.radlab_genomics_project_id
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
  activate_apis = [
    "compute.googleapis.com",
    "lifesciences.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
  ]
}

module "vpc_ngs" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = module.project_radlab_genomics.project_id
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

}

resource "google_service_account" "sa_p_ngs" {
  project      = module.project_radlab_genomics.project_id
  account_id   = format("sa-p-ngs-%s", local.random_id)
  display_name = "NGS in trusted environment"
}

resource "google_project_iam_member" "sa_p_ngs_permissions" {
  for_each = toset(local.ngs_sa_project_roles)
  project  = module.project_radlab_genomics.project_id
  member   = "serviceAccount:${google_service_account.sa_p_ngs.email}"
  role     = each.value
}

resource "google_service_account_iam_member" "sa_ngs_user_iam" {
  for_each           = var.trusted_users
  member             = each.value
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.sa_p_ngs.id
}

resource "google_project_iam_binding" "genomics_ngs_user_role1" {
  project = module.project_radlab_genomics.project_id
  members = var.trusted_users
  role    = "roles/storage.admin"
}

resource "google_project_iam_binding" "genomics_ngs_user_role2" {
  project = module.project_radlab_genomics.project_id
  members = var.trusted_users
  role    = "roles/viewer"
}

# Bucket to store sequence inputs and processed outputs #
resource "google_storage_bucket" "input_bucket" {
  project                     = module.project_radlab_genomics.project_id
  name                        = join("", ["ngs-input-bucket-", local.random_id])
  location                    = local.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_binding" "binding1" {
  bucket  = google_storage_bucket.input_bucket.name
  role    = "roles/storage.admin"
  members = var.trusted_users
}

resource "google_storage_bucket" "output_bucket" {
  project                     = module.project_radlab_genomics.project_id
  name                        = join("", ["ngs-output-bucket-", local.random_id])
  location                    = local.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_binding" "binding2" {
  bucket  = google_storage_bucket.output_bucket.name
  role    = "roles/storage.admin"
  members = var.trusted_users
}

# Bucket to store Cloud functions #
resource "google_storage_bucket" "source_code_bucket" {
  project                     = module.project_radlab_genomics.project_id
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
  project               = module.project_radlab_genomics.project_id
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
    GCP_PROJECT       = module.project_radlab_genomics.project_id
    GCS_OUTPUT_BUCKET = join("", ["gs://", google_storage_bucket.output_bucket.name])
    GCS_LOG_LOCATION  = join("", ["gs://", google_storage_bucket.output_bucket.name, "/logs"])
    CONTAINER_IMAGE   = join("", ["gcr.io/", module.project_radlab_genomics.project_id, "/fastqc:latest"])
    REGION            = local.region
    NETWORK           = module.vpc_ngs.network_name
    SUBNETWORK        = module.vpc_ngs.subnets_names.0
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
    command     = "${path.module}/scripts/build/container/fastqc-0.11.9a/build-container.sh ${module.project_radlab_genomics.project_id}"
  }
}
