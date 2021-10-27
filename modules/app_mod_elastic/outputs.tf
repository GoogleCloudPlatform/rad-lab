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

output "cluster_credentials_cmd" {
  value = local.k8s_credentials_cmd
}

output "network_selflink" {
  value = module.elastic_search_network.network_self_link
}

output "project_id" {
  value = local.project_id
}

output "subnet_selflink" {
  value = module.elastic_search_network.subnets_self_links.0
}

output "gke_cluster_endpoint" {
  sensitive = true
  value     = module.gke_cluster.endpoint
}

output "random_id" {
  value = local.random_id
}
