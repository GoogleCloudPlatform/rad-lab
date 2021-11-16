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
  
  region = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

  notebook_sa_project_roles = [
    "roles/compute.instanceAdmin",
    "roles/notebooks.admin",
    "roles/bigquery.user",
    "roles/storage.objectViewer"
  ]

  radlab_ds_analytics_project_id = "radlab-ds-analytics-${var.random_id}"

  radlab_ds_data_project_id = "radlab-ds-data-${var.random_id}"
}

#####################
# ANALYTICS PROJECT #
#####################

module "project_radlab_ds_analytics" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = local.radlab_ds_analytics_project_id
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id

  activate_apis = [
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "notebooks.googleapis.com",
    "bigquerystorage.googleapis.com",
  ]
}

module "vpc_ai_notebook" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = module.project_radlab_ds_analytics.project_id
  network_name = "ai-notebook"
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform"

  subnets = [
    {
      subnet_name           = "subnet-ai-notebook"
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
        }, {
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
  ]
}

resource "google_project_organization_policy" "external_ip_policy" {
  count      = var.set_external_ip_policy ? 1 : 0
  constraint = "compute.vmExternalIpAccess"
  project    = module.project_radlab_ds_analytics.project_id

  list_policy {
    allow {
      all = true
    }
  }
}

# - Shielded VMs: constraints/compute.requireShieldedVm
resource "google_project_organization_policy" "shielded_vm_policy" {
  count      = var.set_shielded_vm_policy ? 1 : 0
  constraint = "compute.requireShieldedVm"
  project    = module.project_radlab_ds_analytics.project_id

  boolean_policy {
    enforced = false
  }
}

# - Define trusted image projects: constraints/compute.trustedImageProjects
# Use of images from project deeplearning-platform-release is prohibited in Argolis
resource "google_project_organization_policy" "trustedimage_project_policy" {
  count      = var.set_trustedimage_project_policy ? 1 : 0
  constraint = "compute.trustedImageProjects"
  project    = module.project_radlab_ds_analytics.project_id
  list_policy {
    allow {
      values = [
        "is:projects/deeplearning-platform-release",
      ]
    }
  }
}

resource "google_service_account" "sa_p_notebook" {
  project      = module.project_radlab_ds_analytics.project_id
  account_id   = format("sa-p-notebook-%s", var.random_id)
  display_name = "Notebooks in trusted environment"
}

resource "google_project_iam_member" "sa_p_notebook_permissions" {
  for_each = toset(local.notebook_sa_project_roles)
  project  = module.project_radlab_ds_analytics.project_id
  member   = "serviceAccount:${google_service_account.sa_p_notebook.email}"
  role     = each.value
}

resource "google_service_account_iam_member" "sa_ai_notebook_user_iam" {
  for_each           = var.trusted_users
  member             = each.value
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.sa_p_notebook.id
}

resource "google_project_iam_binding" "ai_notebook_user_role1" {
  project = module.project_radlab_ds_analytics.project_id
  members = var.trusted_users
  role    = "roles/notebooks.admin"
}

resource "google_project_iam_binding" "ai_notebook_user_role2" {
  project = module.project_radlab_ds_analytics.project_id
  members = var.trusted_users
  role    = "roles/viewer"
}

resource "google_notebooks_instance" "ai_notebook" {
  count        = var.notebook_count
  project      = module.project_radlab_ds_analytics.project_id
  name         = "notebooks-instance-${count.index}"
  location     = var.zone
  machine_type = var.machine_type

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  service_account = google_service_account.sa_p_notebook.email

  install_gpu_driver = false
  boot_disk_type     = var.boot_disk_type
  boot_disk_size_gb  = var.boot_disk_size_gb

  no_public_ip    = false
  no_proxy_access = false

  network = module.vpc_ai_notebook.network_self_link
  subnet  = module.vpc_ai_notebook.subnets_self_links.0

  post_startup_script = "${path.module}/scripts/build/samplenotebook.sh"

  labels = {
    module = "data-science"
  }

  metadata = {
    terraform  = "true"
    proxy-mode = "mail"
  }
  depends_on = [
    google_project_organization_policy.external_ip_policy,
    google_project_organization_policy.shielded_vm_policy,
    google_project_organization_policy.trustedimage_project_policy
  ]
}

resource "google_storage_bucket" "user_scripts_bucket" {
  project                     = module.project_radlab_ds_analytics.project_id
  name                        = join("", ["user-scripts-notebooks-instance-", var.random_id])
  location                    = "US"
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
  bucket = google_storage_bucket.user_scripts_bucket.name
  role = "roles/storage.admin"
  members = var.trusted_users
}
