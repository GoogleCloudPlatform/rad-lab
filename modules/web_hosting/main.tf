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
    "iap.googleapis.com",
    "networkmanagement.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com"
  ] : []
}

resource "random_id" "default" {
  byte_length = 2
}

#########################################################################
# WEB HOSTING PROJECT
#########################################################################

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
#########################################################################
# Service Account to connect to Cloud SQL
#########################################################################

resource "google_service_account" "sa_p_cloud_sql" {
  project  = local.project.project_id
  account_id   = "gce-sql-sa"
  display_name = "Service Account to connect Cloud SQL"
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
# Creating GCE VMs in vpc-xlb
#########################################################################


resource "google_compute_instance" "web1-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-central1-a"
  name         = "web1-vpc-xlb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
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
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }
 
  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-us-c1
    ]
}

resource "google_compute_instance" "web2-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-central1-b"
  name         = "web2-vpc-xlb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script_video.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
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
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-us-c1
    ]
}
 
resource "google_compute_instance" "web3-vpc-xlb" {
  project      = local.project.project_id
  zone         = "us-central1-f"
  name         = "web3-vpc-xlb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.20.4"
    # access_config {
    #   // Ephemeral IP
    # }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }
  
  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-us-c1
    ]
}
 
resource "google_compute_instance" "web4-vpc-xlb" {
  project      = local.project.project_id
  zone         = "asia-south1-c"
  name         = "web4-vpc-xlb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-xlb-asia-s1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.200.240.2"
    # access_config {
    #   // Ephemeral IP
    # }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-xlb-asia-s1
    ]
}

#########################################################################
# Creating GCE VMs in vpc-ilb
#########################################################################


resource "google_compute_instance" "app1-vpc-ilb" {
  project      = local.project.project_id
  zone         = "us-central1-c"
  name         = "app1-vpc-ilb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-ilb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.100.20.2"
    # access_config {
    #   // Ephemeral IP
    # }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-ilb-us-c1
    ]
}

resource "google_compute_instance" "app2-vpc-ilb" {
  project      = local.project.project_id
  zone         = "us-central1-f"
  name         = "app2-vpc-ilb"
  machine_type = "f1-micro"
  allow_stopping_for_update = true
  metadata_startup_script   = data.template_file.metadata_startup_script.rendered
  metadata = {
    enable-oslogin = true
  }
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20220719"
    }
  }
 
  network_interface {
    subnetwork         = google_compute_subnetwork.subnetwork-vpc-ilb-us-c1.name
    subnetwork_project = local.project.project_id
    network_ip         = "10.100.20.3"
    # access_config {
    #   // Ephemeral IP
    # }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_p_cloud_sql.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    time_sleep.wait_120_seconds,
    google_compute_router_nat.nat-gw-vpc-ilb-us-c1
    ]
}

#########################################################################
# GCS bucket / Bucket Objects / Bucket Bindings
#########################################################################


resource "google_storage_bucket" "gcs_image_bucket" {
  name          = join("",["gcs_image_bucket-",local.project.project_id])
  location      = "US"
  project       = local.project.project_id
  force_destroy = true
  depends_on    = [google_project_service.enabled_services]
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
  members = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
}

#########################################################################
# Unmanaged Instance Group - vpc-xlb
#########################################################################

resource "google_compute_instance_group" "ig-us-c1-content-www" {
  name        = "ig-us-c1-content-www"
  description = "Unmanaged instance group created via terraform"
  project      = local.project.project_id
  instances = [
    google_compute_instance.web1-vpc-xlb.self_link
  ]
 
  named_port {
    name = "http"
    port = "80"
  }
 
  zone = "us-central1-a"
  depends_on = [google_compute_instance.web1-vpc-xlb]
}

resource "google_compute_instance_group" "ig-us-c1-content-video" {
  name        = "ig-us-c1-content-video"
  description = "Unmanaged instance group created via terraform"
  project      = local.project.project_id
  instances = [
    google_compute_instance.web2-vpc-xlb.self_link
  ]
 
  named_port {
    name = "http"
    port = "80"
  }
 
  zone = "us-central1-b"
  depends_on = [google_compute_instance.web2-vpc-xlb]
}

resource "google_compute_instance_group" "ig-us-c1-region" {
  name        = "ig-us-c1-region"
  description = "Unmanaged instance group created via terraform"
  project      = local.project.project_id
  instances = [
    google_compute_instance.web3-vpc-xlb.self_link
  ]
 
  named_port {
    name = "http"
    port = "80"
  }
 
  zone = "us-central1-f"
  depends_on = [google_compute_instance.web3-vpc-xlb]
}
 
resource "google_compute_instance_group" "ig-asia-s1-region" {
  name        = "ig-asia-s1-region"
  description = "Unmanaged instance group created via terraform"
  project      = local.project.project_id
  instances = [
    google_compute_instance.web4-vpc-xlb.self_link
  ]
 
  named_port {
    name = "http"
    port = "80"
  }
 
  zone = "asia-south1-c"
  depends_on = [google_compute_instance.web4-vpc-xlb]
}

#########################################################################
# Unmanaged Instance Group - vpc-ilb
#########################################################################

resource "google_compute_instance_group" "ig-ilb-us-c1-c" {
  name        = "ig-ilb-us-c1-c"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id
  instances = [
    google_compute_instance.app1-vpc-ilb.self_link,
  ]
  named_port {
    name = "http"
    port = "80"
  }
  zone = "us-central1-c"
}

resource "google_compute_instance_group" "ig-ilb-us-c1-f" {
  name        = "ig-ilb-us-c1-f"
  description = "Unmanaged instance group created via terraform"
  project     = local.project.project_id
  instances = [
    google_compute_instance.app2-vpc-ilb.self_link,
  ]
  named_port {
    name = "http"
    port = "80"
  }
  zone = "us-central1-f"
}

#########################################################################
# Cloud Armor
#########################################################################

 
resource "google_compute_security_policy" "policy" {
  name     = "security-policy"
  project  = local.project.project_id
 
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

resource "google_compute_backend_bucket" "be-http-cdn-gcs" {
  name        =  "be-http-cdn-gcs"
  description = "Contains test images"
  project     = local.project.project_id
  bucket_name = google_storage_bucket.gcs_image_bucket.name
  enable_cdn  = true
}

#########################################################################
# L7 HTTP Load Balancer  - Health Check
#########################################################################

resource "google_compute_health_check" "http-hc" {
  name               = "http-hc"
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check {
    port             = 80
    request_path     = "/"
  }
  project            = local.project.project_id
}

#########################################################################
# Global HTTP Load Balancer  - Content Based
#########################################################################
 
resource "google_compute_backend_service" "be-http-content-based-www" {
  name         = "be-http-content-based-www"
  port_name    = "http"
  protocol     = "HTTP"
  project      = local.project.project_id
  timeout_sec  = 10
  backend {
    group = google_compute_instance_group.ig-us-c1-content-www.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  health_checks = [google_compute_health_check.http-hc.id]
}

resource "google_compute_backend_service" "be-http-content-based-video" {
  name            = "be-http-content-based-video"
  port_name       = "http"
  protocol        = "HTTP"
  security_policy = google_compute_security_policy.policy.name
  project         = local.project.project_id
  timeout_sec     = 10
  backend {
    group = google_compute_instance_group.ig-us-c1-content-video.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  health_checks   = [google_compute_health_check.http-hc.id]
}

resource "google_compute_url_map" "http-lb-content-based" {
  name            = "http-lb-content-based"
  description     = "L7 Global load balancer Content based"
  project         = local.project.project_id
  default_service = google_compute_backend_service.be-http-content-based-www.id
 
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
 
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.be-http-content-based-www.id
 
    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.be-http-content-based-www.id
    }

    path_rule {
      paths   = ["/video", "/video/*"]
      service = google_compute_backend_service.be-http-content-based-video.id
    }

  }
}

resource "google_compute_target_http_proxy" "target-proxy-content-based" {
  project     = local.project.project_id
  name        = "target-proxy-content-based"
  url_map     = google_compute_url_map.http-lb-content-based.self_link
}
 
resource "google_compute_global_forwarding_rule" "fe-http-content-based" {
  name       = "fe-http-content-based"
  target     = google_compute_target_http_proxy.target-proxy-content-based.self_link
  port_range = "80"
  project    = local.project.project_id
}

#########################################################################
# Global HTTP Load Balancer  - Cross Region
#########################################################################

resource "google_compute_backend_service" "be-http-cross-region" {
  name         = "be-http-cross-region"
  port_name    = "http"
  protocol     = "HTTP"
  project      = local.project.project_id
  timeout_sec  = 10
  backend {
    group = google_compute_instance_group.ig-us-c1-region.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.ig-asia-s1-region.self_link
  }

  health_checks = [google_compute_health_check.http-hc.id]
}

resource "google_compute_url_map" "http-lb-cross-region" {
  name        = "http-lb-cross-region"
  description = "L7 Global load balancer Cross Region"
  project      = local.project.project_id
  default_service = google_compute_backend_service.be-http-cross-region.id
 
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
 
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.be-http-cross-region.id
 
    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.be-http-cross-region.id
    }
    path_rule {
      paths = ["/images/*"]
      service = google_compute_backend_bucket.be-http-cdn-gcs.id
    }
  }
}

resource "google_compute_target_http_proxy" "target-proxy-cross-region" {
  project     = local.project.project_id
  name        = "target-proxy-cross-region"
  url_map     = google_compute_url_map.http-lb-cross-region.self_link
}

resource "google_compute_global_forwarding_rule" "fe-http-cross-region-cdn" {
  name       = "fe-http-cross-region-cdn"
  target     = google_compute_target_http_proxy.target-proxy-cross-region.self_link
  port_range = "80"
  project    = local.project.project_id
}

#########################################################################
# L7 HTTP Load Balancer  - Health Check
#########################################################################

resource "google_compute_health_check" "ilb-hc" {
  name               = "ilb-hc"
  timeout_sec        = 1
  check_interval_sec = 1
  tcp_health_check {
    port             = 80
  }
  project            = local.project.project_id
}

#########################################################################
# Internal Load Balancer
#########################################################################

resource "google_compute_region_backend_service" "be-ilb" {
  name                  = "be-ilb"
  project               = local.project.project_id
  region                = "us-central1"
  backend {
    group = google_compute_instance_group.ig-ilb-us-c1-c.self_link
  }
  backend {
    group = google_compute_instance_group.ig-ilb-us-c1-f.self_link
  }
  health_checks         = [google_compute_health_check.ilb-hc.id]
}

resource "google_compute_forwarding_rule" "ilb" {
  name                  = "ilb"
  project               = local.project.project_id
  region                = "us-central1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be-ilb.id
  all_ports             = true
  allow_global_access   = true
  network               = google_compute_network.vpc-ilb.name
  subnetwork            = google_compute_subnetwork.subnetwork-vpc-ilb-us-c1.name
}

#########################################################################
# IAM - Trusted User/Group
#########################################################################

resource "google_project_iam_member" "trusted_user_group_role1" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/iap.tunnelResourceAccessor"
}

resource "google_project_iam_member" "trusted_user_group_role2" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/compute.instanceAdmin.v1"
}

resource "google_project_iam_member" "trusted_user_group_role3" {
  for_each = toset(concat(formatlist("user:%s", var.trusted_users), formatlist("group:%s", var.trusted_groups)))
  project  = local.project.project_id
  member   = each.value
  role     = "roles/viewer"
}

resource "google_project_iam_member" "sa_p_cloud_sql_permissions" {
  project  = local.project.project_id
  role     = "roles/cloudsql.client"
  member   = format("serviceAccount:%s@%s.iam.gserviceaccount.com", google_service_account.sa_p_cloud_sql.account_id,local.project.project_id)
}