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

output "deployment_id" {
  description = "RADLab Module Deployment ID"
  value       = module.project.deployment_id
}

output "cluster_credentials_cmd" {
  value = "gcloud container clusters get-credentials ${module.argocd_management_cluster.name} --region ${module.argocd_management_cluster.region} --project ${module.project.project_id}"
}

output "project_id" {
  value = module.project.project_id
}

output "argo_cd_mgmt_identity" {
  value = google_service_account.argocd_management_identity.email
}