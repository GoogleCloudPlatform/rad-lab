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

module "project" {
  source = "../../helpers/tf-support-modules/project"

  billing_account_id = var.billing_account_id
  project_id_prefix  = var.project_id_prefix
  create_project     = var.create_project
  deployment_id      = var.deployment_id
  folder_id          = var.folder_id
  organization_id    = var.organization_id

  project_apis = [
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "connectgateway.googleapis.com",
    "container.googleapis.com"
  ]
}

module "network" {
  source = "../../helpers/tf-support-modules/net-vpc"

  project_id     = module.project.project_id
  create_network = var.create_network
  name           = var.network_name
  subnets        = var.subnets
}

module "argocd_management_cluster" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster-update-variant"

  project_id        = module.project.project_id
  name              = var.argo_cd_management_cluster_name
  region            = var.argo_cd_management_cluster_region
  network           = module.network.network.name
  ip_range_pods     = "pod-ip-range"
  ip_range_services = "svc-ip-range"
  subnetwork        = module.network.subnets["us-east1/argocd-mgmt-snw-useast1"].name
}

resource "google_gke_hub_membership" "argocd_management_cluster_fleet" {
  provider      = google-beta
  project       = module.project.project_id
  membership_id = "argocd-mgmt-cluster"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.argocd_management_cluster.cluster_id}"
    }
  }
}