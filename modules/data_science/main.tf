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
  random_id = var.random_id != null ? var.random_id : random_id.default.0.hex
  project = (var.create_project
    ? try(module.project_radlab_ds_analytics.0, null)
    : try(data.google_project.existing_project.0, null)
  )
  region = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

  network = (
    var.create_network
    ? try(module.vpc_ai_notebook.0.network.network, null)
    : try(data.google_compute_network.default.0, null)
  )

  subnet = (
    var.create_network
    ? try(module.vpc_ai_notebook.0.subnets["${local.region}/${var.subnet_name}"], null)
    : try(data.google_compute_subnetwork.default.0, null)
  )

  notebook_sa_project_roles = [
    "roles/compute.instanceAdmin",
    "roles/notebooks.admin",
    "roles/bigquery.user",
    "roles/storage.objectViewer",
    "roles/iam.serviceAccountUser"
  ]

  project_services = var.enable_services ? [
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "notebooks.googleapis.com",
    "bigquerystorage.googleapis.com"
  ] : []
}

resource "random_id" "default" {
  count       = var.random_id == null ? 1 : 0
  byte_length = 2
}

#####################
# ANALYTICS PROJECT #
#####################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_name
}

module "project_radlab_ds_analytics" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  name              = var.use_random_id ? format("%s-%s", var.project_name, local.random_id) : var.project_name
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
    module.project_radlab_ds_analytics
  ]
}

resource "time_sleep" "wait_enabled_services" {
  depends_on = [
    google_project_service.enabled_services,
  ]

  create_duration = "1440s"
}

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.subnet_name
  region  = local.region
}

module "vpc_ai_notebook" {
  count   = var.create_network && var.create_usermanaged_notebook ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = local.project.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.ip_cidr_range
      subnet_region         = local.region
      description           = "Subnetwork inside *vpc-analytics* VPC network, created via Terraform"
      subnet_private_access = true
    }
  ]

  firewall_rules = [
    {
      name        = "fw-ai-notebook-allow-internal"
      description = "Firewall rule to allow traffic on all ports inside *vpc-analytics* VPC network."
      priority    = 65534
      ranges      = ["10.0.0.0/8"]
      direction   = "INGRESS"

      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
  ]

  depends_on = [
    google_project_service.enabled_services
  ]
}

resource "google_service_account" "sa_p_notebook" {
  project      = local.project.project_id
  account_id   = format("sa-p-notebook-%s", local.random_id)
  display_name = "Notebooks in trusted environment"
}

resource "google_project_iam_member" "sa_p_notebook_permissions" {
  for_each = toset(local.notebook_sa_project_roles)
  project  = local.project.project_id
  member   = "serviceAccount:${google_service_account.sa_p_notebook.email}"
  role     = each.value
}

resource "google_service_account_iam_member" "sa_ai_notebook_iam" {
  for_each           = var.trusted_users
  member             = each.value
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.sa_p_notebook.id
}

resource "google_project_iam_member" "module_role1" {
  for_each = var.trusted_users
  project  = local.project.project_id
  member   = each.value
  role     = "roles/notebooks.admin"
}

resource "google_project_iam_member" "module_role2" {
  for_each = var.trusted_users
  project  = local.project.project_id
  member   = each.value
  role     = "roles/viewer"
}

resource "google_notebooks_instance" "ai_notebook_usermanaged" {
  count        = (var.notebook_count > 0 ? true : false) && var.create_usermanaged_notebook ? var.notebook_count : 0
  project      = local.project.project_id
  name         = "usermanaged-notebooks-${count.index + 1}"
  location     = var.zone
  machine_type = var.machine_type

  dynamic "vm_image" {
    for_each = var.create_container_image ? [] : [1]
    content {
      project      = var.image_project
      image_family = var.image_family
    }
  }

  dynamic "container_image" {
    for_each = var.create_container_image ? [1] : []
    content {
      repository = var.container_image_repository
      tag        = var.container_image_tag
    }
  }

  install_gpu_driver = var.enable_gpu_driver

  dynamic "accelerator_config" {
    for_each = var.enable_gpu_driver ? [1] : []
    content {
      type       = var.gpu_accelerator_type
      core_count = var.gpu_accelerator_core_count
    }
  }

  service_account = google_service_account.sa_p_notebook.email

  boot_disk_type    = var.boot_disk_type
  boot_disk_size_gb = var.boot_disk_size_gb

  no_public_ip    = false
  no_proxy_access = false

  network = local.network.self_link
  subnet  = local.subnet.self_link

  post_startup_script = format("gs://%s/%s", google_storage_bucket.user_scripts_bucket.name, google_storage_bucket_object.notebook_post_startup_script.name)

  labels = {
    module = "data-science"
  }

  metadata = {
    terraform  = "true"
    proxy-mode = "mail"
  }
  depends_on = [
    time_sleep.wait_120_seconds,
    time_sleep.wait_enabled_services,
    google_storage_bucket_object.notebooks,
  ]
}

resource "google_notebooks_runtime" "ai_notebook_googlemanaged" {
  count    = (var.notebook_count > 0 ? true : false) && !var.create_usermanaged_notebook ? var.notebook_count : 0
  name     = "googlemanaged-notebooks-${count.index + 1}"
  project  = local.project.project_id
  location = local.region
  access_config {
    access_type   = "SERVICE_ACCOUNT"
    runtime_owner = google_service_account.sa_p_notebook.email
  }
  software_config {
    post_startup_script          = format("gs://%s/%s", google_storage_bucket.user_scripts_bucket.name, google_storage_bucket_object.notebook_post_startup_script.name)
    post_startup_script_behavior = "RUN_EVERY_START"
  }
  virtual_machine {
    virtual_machine_config {
      machine_type = var.machine_type
      dynamic "container_images" {
        for_each = var.create_container_image ? [1] : []
        content {
          repository = var.container_image_repository
          tag        = var.container_image_tag
        }
      }
      data_disk {
        initialize_params {
          disk_size_gb = var.boot_disk_size_gb
          disk_type    = var.boot_disk_type
        }
      }
      dynamic "accelerator_config" {
        for_each = var.enable_gpu_driver ? [1] : []
        content {
          type       = var.gpu_accelerator_type
          core_count = var.gpu_accelerator_core_count
        }
      }
    }
  }
  depends_on = [
    time_sleep.wait_120_seconds,
    time_sleep.wait_enabled_services,
    google_storage_bucket_object.notebooks,
  ]
}

resource "google_storage_bucket" "user_scripts_bucket" {
  project                     = local.project.project_id
  name                        = join("", ["user-scripts-", local.project.project_id])
  location                    = local.region
  force_destroy               = true
  uniform_bucket_level_access = true

  cors {
    origin          = ["http://user-scripts"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.user_scripts_bucket.name
  role    = "roles/storage.admin"
  members = var.trusted_users
}
