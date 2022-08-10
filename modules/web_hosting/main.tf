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
  random_id = var.random_id != null ? var.random_id : random_id.default.hex
  project = (var.create_project
    ? try(module.project_radlab_web_hosting.0, null)
    : try(data.google_project.existing_project.0, null)
  )
  # region = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

  # network = (
  #   var.create_network
  #   ? try(module.vpc_workbench.0.network.network, null)
  #   : try(data.google_compute_network.default.0, null)
  # )

  # subnet = (
  #   var.create_network
  #   ? try(module.vpc_workbench.0.subnets["${local.region}/${var.subnet_name}"], null)
  #   : try(data.google_compute_subnetwork.default.0, null)
  # )

  project_services = var.enable_services ? [
    "compute.googleapis.com",
  ] : []
}

resource "random_id" "default" {
  byte_length = 2
}

#######################
# WEB HOSTING PROJECT #
#######################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_name
}

module "project_radlab_web_hosting" {
  count               = var.create_project ? 1 : 0
  source              = "terraform-google-modules/project-factory/google"
  version             = "~> 13.0"
  name                = format("%s-%s", var.project_name, local.random_id)
  random_project_id   = false
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
  org_id              = var.organization_id
}

resource "google_project_service" "enabled_services" {
  for_each                   = toset(local.project_services)
  project                    = local.project.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    module.project_radlab_web_hosting
  ]
}

resource "google_compute_network" "vpc-xlb" {
  name                    = "vpc-xlb"
  project                 = local.project.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.enabled_services]
}

# Creating Sunbet for vpc-xlb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-xlb-us-e1" {
  name                     = "vpc-xlb-us-e1"
  ip_cidr_range            = "10.200.10.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vpc-xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc-xlb]
}

# Creating Sunbet for vpc-xlb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-xlb-us-c1" {
  name                     = "vpc-xlb-us-c1"
  ip_cidr_range            = "10.200.20.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc-xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc-xlb]
}

# Creating Sunbet for vpc-xlb VPC network

resource "google_compute_subnetwork" "subnetwork-vpc-xlb-asia-e1" {
  name                     = "vpc-xlb-asia-e1"
  ip_cidr_range            = "10.200.240.0/20"
  region                   = "asia-east1"
  network                  = google_compute_network.vpc-xlb.name
  project                  = local.project.project_id
  private_ip_google_access = true
  depends_on               = [google_compute_network.vpc-xlb]
}

#########################################################################
# Startup script for VMs in vpc-xlb
#########################################################################

data "template_file" "metadata_startup_script" {
    template = "${file("./scripts/build/webapp.sh")}"
}

data "template_file" "metadata_startup_script_video" {
    template = "${file("./scripts/build/video_webapp.sh")}"
}


#########################################################################
# Creating 4 GCE VMs in vpc-xlb
#########################################################################


resource "google_compute_instance" "web1-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-east1-b"
  name         = "web1-vpc-xlb"
  machine_type = "f1-micro"
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-us-e1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.10.2"
    # access_config {
    #   // Ephemeral IP
    # }
  }
 
  depends_on = [
    time_sleep.wait_120_seconds
    ]
}

resource "google_compute_instance" "web2-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-central1-a"
  name         = "web2-vpc-xlb"
  machine_type = "f1-micro"
  metadata_startup_script   = data.template_file.metadata_startup_script_video.rendered
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.20.2"
    # access_config {
    #   // Ephemeral IP
    # }
  }
 
  depends_on = [
    time_sleep.wait_120_seconds
    ]
}
 
resource "google_compute_instance" "web3-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-central1-f"
  name         = "web3-vpc-xlb"
  machine_type = "f1-micro"
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.20.3"
    # access_config {
    #   // Ephemeral IP
    # }
  }
 
  depends_on = [
    time_sleep.wait_120_seconds
    ]
}
 
resource "google_compute_instance" "web4-vpc-xlb" {
  project      = local.project.project_id
  zone         = "asia-east1-c"
  name         = "web4-vpc-xlb"
  machine_type = "f1-micro"
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-asia-e1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.240.2"
    # access_config {
    #   // Ephemeral IP
    # }
  }
 
  depends_on = [
    time_sleep.wait_120_seconds
    ]
}

#########################################################################
# Cloud CDN with GCS bucket
#########################################################################


resource "google_storage_bucket" "gcs_image_bucket" {
  name     = join("",["gcs_image_bucket-",local.random_id])
  location = "US"
  project      = local.project.project_id
  depends_on = [google_project_service.enabled_services]
  force_destroy = true
}

resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.picture.name
  bucket = google_storage_bucket.gcs_image_bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "picture" {
  name   = "countryRoad.jpg"
  source = "./scripts/build/img/clear-day-brock-mountain-drive_800.jpg"
  bucket = google_storage_bucket.gcs_image_bucket.name
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.gcs_image_bucket.name
  role    = "roles/storage.admin"
  members = var.trusted_users
}


resource "google_project_iam_member" "user_role1" {
  for_each = var.trusted_users
  project  = local.project.project_id
  member   = each.value
  role     = "roles/viewer"
}

# resource "google_storage_bucket" "user_scripts_bucket" {
#   project                     = local.project.project_id
#   name                        = join("", ["user-scripts-", local.project.project_id])
#   location                    = "US"
#   force_destroy               = true
#   uniform_bucket_level_access = true

#   cors {
#     origin          = ["http://user-scripts"]
#     method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
#     response_header = ["*"]
#     max_age_seconds = 3600
#   }
# }

# resource "google_storage_bucket_iam_binding" "binding" {
#   bucket  = google_storage_bucket.user_scripts_bucket.name
#   role    = "roles/storage.admin"
#   members = var.trusted_users
# }