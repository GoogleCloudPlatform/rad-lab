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

data "google_compute_zones" "zones" {
  project = module.elastic_search_project.project_id
  region  = var.region
}

module "gke_cluster" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                    = "~> 17.0"
  project_id                 = module.elastic_search_project.project_id
  name                       = var.gke_cluster_name
  region                     = var.region
  network                    = module.elastic_search_network.network_self_link
  subnetwork                 = module.elastic_search_network.subnets_self_links.0
  remove_default_node_pool   = true
  initial_node_count         = 1
  ip_range_pods              = var.pod_cidr_block
  ip_range_services          = var.service_cidr_block
  regional                   = true
  release_channel            = "RAPID"
  issue_client_certificate   = false
  identity_namespace         = "${module.elastic_search_project.project_id}.svc.google.com"
  create_service_account     = true
  enable_private_nodes       = true
  enable_private_endpoint    = true
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  horizontal_pod_autoscaling = true

  node_pools = [
    {
      name           = var.node_pool_name
      machine_type   = var.node_pool_machine_type
      node_locations = join(",", data.google_compute_zones.zones.names)
      min_count      = 1
      max_count      = 10
      image_type     = "COS"
      preemptible    = false
    }
  ]

  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}