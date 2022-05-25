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

output "name" {
  description = "Name of the VPC being created."
  value       = local.network.name
  depends_on = [
    google_service_networking_connection.psa_connection
  ]
}

output "network" {
  description = "VPC resource"
  value       = local.network
  depends_on = [
    google_service_networking_connection.psa_connection
  ]
}

output "self_link" {
  description = "The URI of the VPC being created."
  value       = local.network.self_link
  depends_on = [
    google_service_networking_connection.psa_connection
  ]
}

output "subnets" {
  description = "Subnet resources"
  value       = { for k, v in google_compute_subnetwork.subnet : k => v }

  depends_on = [
    google_service_networking_connection.psa_connection
  ]
}