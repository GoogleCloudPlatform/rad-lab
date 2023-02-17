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
    ? try(module.project_radlab_web_hosting.0, null)
    : try(data.google_project.existing_project.0, null)
  )

  default_apis = [
    "compute.googleapis.com",
    "iap.googleapis.com",
    "networkmanagement.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]

  project_services = var.enable_services ? (var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis, [
    "pubsub.googleapis.com"
  ])) : local.default_apis) : []

  web_startup_script = templatefile("${path.module}/scripts/build/startup_scripts/sample_app/sample_webapp.sh.tpl", {
    INSTANCE_CONNECTION_NAME = module.sql_db_postgresql.instance_connection_name
    CLOUD_SQL_DATABASE_NAME  = "postgres"
    CLOUD_SQL_USERNAME       = module.sql_db_postgresql.additional_users[0].name
    CLOUD_SQL_PASSWORD       = module.sql_db_postgresql.additional_users[0].password
  })

  sample_app_startup_script = templatefile("${path.module}/scripts/build/startup_scripts/sample_app/sample_app.sh.tpl", {})
}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

data "google_compute_zones" "primary_available_zones" {
  project = local.project.project_id
  region  = var.region
  status  = "UP"
}

data "google_compute_zones" "secondary_available_zones" {
  project = local.project.project_id
  region  = var.region_secondary
  status  = "UP"
}

#########################################################################
# WEB HOSTING PROJECT
#########################################################################

data "google_project" "existing_project" {
  count      = var.create_project ? 0 : 1
  project_id = var.project_id_prefix
}

module "project_radlab_web_hosting" {
  count             = var.create_project ? 1 : 0
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 13.0"
  name              = format("%s-%s", var.project_id_prefix, local.random_id)
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
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

#########################################################################
# Service Account to connect to Cloud SQL
#########################################################################
resource "google_service_account" "sa_p_cloud_sql" {
  project      = local.project.project_id
  account_id   = "gce-sql-sa"
  display_name = "Service Account to connect Cloud SQL"
}

#########################################################################
# Creating GCE VMs in vpc-xlb
#########################################################################

data "google_compute_image" "debian_11_bullseye" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance" "web1_vpc_xlb" {
  project                   = local.project.project_id
  zone                      = data.google_compute_zones.primary_available_zones.names.0
  name                      = "web1-vpc-xlb"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = local.web_startup_script
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_11_bullseye.self_link
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork_primary.name
    subnetwork_project = local.project.project_id
    network_ip         = cidrhost(google_compute_subnetwork.subnetwork_primary.ip_cidr_range, 2)
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat_gw_region_primary
  ]
}

resource "google_compute_instance" "web2_vpc_xlb" {
  project                   = local.project.project_id
  zone                      = data.google_compute_zones.primary_available_zones.names.1
  name                      = "web2-vpc-xlb"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = local.web_startup_script
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_11_bullseye.self_link
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork_primary.name
    subnetwork_project = local.project.project_id
    network_ip         = cidrhost(google_compute_subnetwork.subnetwork_primary.ip_cidr_range, 3)
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat_gw_region_primary
  ]
}

resource "google_compute_instance" "web3_vpc_xlb" {
  project                   = local.project.project_id
  zone                      = data.google_compute_zones.primary_available_zones.names.2
  name                      = "web3-vpc-xlb"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = local.web_startup_script

  metadata = {
    enable-oslogin = true
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_11_bullseye.self_link
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork_primary.name
    subnetwork_project = local.project.project_id
    network_ip         = cidrhost(google_compute_subnetwork.subnetwork_primary.ip_cidr_range, 4)
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat_gw_region_primary
  ]
}

resource "google_compute_instance" "web4_vpc_xlb" {
  project                   = local.project.project_id
  zone                      = data.google_compute_zones.secondary_available_zones.names.2
  name                      = "web4-vpc-xlb"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = local.sample_app_startup_script

  metadata = {
    enable-oslogin = true
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_11_bullseye.self_link
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork_secondary.name
    subnetwork_project = local.project.project_id
    network_ip         = cidrhost(google_compute_subnetwork.subnetwork_secondary.ip_cidr_range, 2)
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat_gw_region_secondary
  ]
}


#########################################################################
# GCS bucket / Bucket Objects / Bucket Bindings
#########################################################################


resource "google_storage_bucket" "gcs_image_bucket" {
  name          = join("", ["gcs_image_bucket-", local.project.project_id])
  location      = var.region
  project       = local.project.project_id
  force_destroy = true
  depends_on = [
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]
}

resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.picture.name
  bucket = google_storage_bucket.gcs_image_bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "picture" {
  name   = "images/countryRoad.jpg"
  source = "./scripts/build/img/clear-day-brock-mountain-drive_800.jpg"
  bucket = google_storage_bucket.gcs_image_bucket.name
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.gcs_image_bucket.name
  role    = "roles/storage.admin"
  members = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
}

#########################################################################
# Unmanaged Instance Group - vpc-xlb
#########################################################################

resource "google_compute_instance_group" "ig_us_c1_content_list" {
  name        = "ig-us-c1-content-list"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id
  instances = [
    google_compute_instance.web1_vpc_xlb.self_link
  ]

  named_port {
    name = "http"
    port = "80"
  }

  zone       = data.google_compute_zones.primary_available_zones.names.0
  depends_on = [google_compute_instance.web1_vpc_xlb]
}

resource "google_compute_instance_group" "ig_us_c1_content_create" {
  name        = "ig-us-c1-content-create"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id
  instances = [
    google_compute_instance.web2_vpc_xlb.self_link
  ]

  named_port {
    name = "http"
    port = "80"
  }

  zone       = data.google_compute_zones.primary_available_zones.names.1
  depends_on = [google_compute_instance.web2_vpc_xlb]
}

resource "google_compute_instance_group" "ig_us_c1_region" {
  name        = "ig-us-c1-region"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id
  instances = [
    google_compute_instance.web3_vpc_xlb.self_link
  ]

  named_port {
    name = "http"
    port = "80"
  }

  zone       = data.google_compute_zones.primary_available_zones.names.2
  depends_on = [google_compute_instance.web3_vpc_xlb]
}

resource "google_compute_instance_group" "ig_secondary_region" {
  name        = "ig-${var.region_secondary}-region"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id

  instances = [
    google_compute_instance.web4_vpc_xlb.self_link
  ]

  named_port {
    name = "http"
    port = "80"
  }

  zone       = data.google_compute_zones.secondary_available_zones.names.2
  depends_on = [google_compute_instance.web4_vpc_xlb]
}


#########################################################################
# Cloud Armor
#########################################################################
resource "google_compute_security_policy" "policy" {
  name    = "security-policy"
  project = local.project.project_id

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["9.9.9.0/24"]
      }
    }
    description = "Deny access to IPs in 9.9.9.0/24"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

#########################################################################
# Cloud CDN with GCS bucket
#########################################################################

resource "google_compute_backend_bucket" "be_http_cdn_gcs" {
  name        = "be-http-cdn-gcs"
  description = "Contains test images"
  project     = local.project.project_id
  bucket_name = google_storage_bucket.gcs_image_bucket.name
  enable_cdn  = true
}

#########################################################################
# L7 HTTP Load Balancer  - Health Check
#########################################################################

resource "google_compute_health_check" "http_hc" {
  name               = "http-hc"
  timeout_sec        = 1
  check_interval_sec = 30
  http_health_check {
    port         = 80
    request_path = "/hc"
  }
  project = local.project.project_id
}

#########################################################################
# Global HTTP Load Balancer  - Content Based
#########################################################################

resource "google_compute_backend_service" "be_http_content_based_list" {
  name        = "be-http-content-based-list"
  port_name   = "http"
  protocol    = "HTTP"
  project     = local.project.project_id
  timeout_sec = 10
  backend {
    group           = google_compute_instance_group.ig_us_c1_content_list.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  health_checks = [google_compute_health_check.http_hc.id]
}

resource "google_compute_backend_service" "be_http_content_based_create" {
  name            = "be-http-content-based-create"
  port_name       = "http"
  protocol        = "HTTP"
  security_policy = google_compute_security_policy.policy.name
  project         = local.project.project_id
  timeout_sec     = 10
  backend {
    group           = google_compute_instance_group.ig_us_c1_content_create.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  health_checks = [google_compute_health_check.http_hc.id]
}

resource "google_compute_url_map" "http_lb_content_based" {
  name            = "http-lb-content-based"
  description     = "L7 Global load balancer Content based"
  project         = local.project.project_id
  default_service = google_compute_backend_service.be_http_content_based_list.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.be_http_content_based_list.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.be_http_content_based_list.id
    }

    path_rule {
      paths   = ["/create", "/create/*", "/delete", "/delete/*"]
      service = google_compute_backend_service.be_http_content_based_create.id
    }

  }
}

resource "google_compute_target_http_proxy" "target_proxy_content_based" {
  project = local.project.project_id
  name    = "target-proxy-content-based"
  url_map = google_compute_url_map.http_lb_content_based.self_link
}

resource "google_compute_global_forwarding_rule" "fe_http_content_based" {
  name       = "fe-http-content-based"
  target     = google_compute_target_http_proxy.target_proxy_content_based.self_link
  port_range = "80"
  project    = local.project.project_id
}

#########################################################################
# Global HTTP Load Balancer  - Cross Region
#########################################################################

resource "google_compute_backend_service" "be_http_cross_region" {
  name        = "be-http-cross-region"
  port_name   = "http"
  protocol    = "HTTP"
  project     = local.project.project_id
  timeout_sec = 10
  backend {
    group           = google_compute_instance_group.ig_us_c1_region.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.ig_secondary_region.self_link
  }

  health_checks = [google_compute_health_check.http_hc.id]
}

resource "google_compute_url_map" "http_lb_cross_region" {
  name            = "http-lb-cross-region"
  description     = "L7 Global load balancer Cross Region"
  project         = local.project.project_id
  default_service = google_compute_backend_service.be_http_cross_region.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.be_http_cross_region.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.be_http_cross_region.id
    }
    path_rule {
      paths   = ["/images/*"]
      service = google_compute_backend_bucket.be_http_cdn_gcs.id
    }
  }
}

resource "google_compute_target_http_proxy" "target_proxy_cross_region" {
  project = local.project.project_id
  name    = "target-proxy-cross-region"
  url_map = google_compute_url_map.http_lb_cross_region.self_link
}

resource "google_compute_global_forwarding_rule" "fe_http_cross_region_cdn" {
  name       = "fe-http-cross-region-cdn"
  target     = google_compute_target_http_proxy.target_proxy_cross_region.self_link
  port_range = "80"
  project    = local.project.project_id
}