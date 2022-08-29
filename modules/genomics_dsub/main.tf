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
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.reader",
    "roles/run.invoker",
    "roles/eventarc.eventReceiver"
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
    "eventarc.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com"
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
data "google_storage_project_service_account" "gcs_sa" {
  project = module.project_radlab_genomics.project_id

  depends_on = [
    # See https://github.com/hashicorp/terraform/issues/29555
    module.project_radlab_genomics.project_id
  ]
}

resource "google_project_iam_member" "gcs_sa_pubsub_publisher" {
  project = module.project_radlab_genomics.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

resource "google_storage_bucket_iam_member" "sa_p_ngs_input_bucket" {
  bucket = google_storage_bucket.input_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.sa_p_ngs.email}"
}

resource "google_storage_bucket_iam_member" "sa_p_ngs_output_bucket" {
  bucket = google_storage_bucket.output_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.sa_p_ngs.email}"
}

resource "google_cloudfunctions2_function" "function" {
  provider    = google-beta
  name        = "ngs-qc-fastqc-fn"
  description = "Cloud function that uses dsub to execute pipeline jobs using lifesciences api in GCP."
  project     = module.project_radlab_genomics.project_id
  location    = local.region

  build_config {
    runtime     = "python38"
    entry_point = "ngs_qc_trigger"
    source {
      storage_source {
        bucket = google_storage_bucket.source_code_bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.sa_p_ngs.email
    ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
    environment_variables = {
      GCP_PROJECT       = module.project_radlab_genomics.project_id
      GCS_OUTPUT_BUCKET = join("", ["gs://", google_storage_bucket.output_bucket.name])
      GCS_LOG_LOCATION  = join("", ["gs://", google_storage_bucket.output_bucket.name, "/logs"])
      CONTAINER_IMAGE   = join("", ["${local.region}-docker.pkg.dev/", module.project_radlab_genomics.project_id, "/fastqc/fastqc:latest"])
      REGION            = local.region
      NETWORK           = module.vpc_ngs.network_name
      SUBNETWORK        = module.vpc_ngs.subnets_names.0
      ZONES             = var.zone
      DISK_SIZE         = var.boot_disk_size_gb
      SERVICE_ACCOUNT   = google_service_account.sa_p_ngs.email
    }
  }

  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.input_bucket.name
    }
  }

  depends_on = [
    google_project_iam_member.sa_p_ngs_permissions,
    google_project_iam_member.gcs_sa_pubsub_publisher,
    google_storage_bucket_iam_member.sa_p_ngs_input_bucket,
    google_storage_bucket_iam_member.sa_p_ngs_output_bucket
  ]
}

# Locally build container for bioinformatics tool and push to artifact registry #
resource "google_artifact_registry_repository" "fastqc" {
  project       = module.project_radlab_genomics.project_id
  location      = var.region
  repository_id = "fastqc"
  format        = "DOCKER"
}

resource "null_resource" "create_cloudbuild_bucket" {
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts"
    command     = "./create-cloud-build-bucket.sh ${module.project_radlab_genomics.project_id} ${local.region}"
  }
}

resource "null_resource" "build_and_push_image" {
  triggers = {
    cloudbuild_yaml_sha = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/cloudbuild.yaml"))
    dockerfile_sha      = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/Dockerfile"))
    build_script_sha    = sha1(file("${path.module}/scripts/build/container/fastqc-0.11.9a/build-container.sh"))
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "${path.module}/scripts/build/container/fastqc-0.11.9a/build-container.sh ${module.project_radlab_genomics.project_id} ${local.region}"
  }

  depends_on = [
    google_artifact_registry_repository.fastqc,
    null_resource.create_cloudbuild_bucket
  ]
}

resource "google_billing_budget" "budget" {
  billing_account = var.billing_account_id
  display_name    = "Billing Budget"

  budget_filter {
    projects = ["projects/${var.project_name}"]
  }

  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = var.amount
    }
  }

  threshold_rules {
    threshold_percent = 1.0
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    treshhold_percent = 0.5
  }
  threshold_rules {
    treshhold_percent = 0.25
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.notification_channel.id,
    ]
    disable_default_iam_recipients = true
  }
}

resource "google_monitoring_notification_channel" "scientist_notification_channel" {
  display_name = "Budget Notification Channel for scientist"
  type         = "email"

  labels = {
    email_address = var.owner
  }
}

resource "google_monitoring_notification_channel" "manager_notification_channel" {
  display_name = "Budget Notification Channel for manager"
  type         = "email"

  labels = {
    email_address = var.manager
  }
}