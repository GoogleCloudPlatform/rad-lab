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
  argocd_identity_roles = [
    "roles/gkehub.gatewayEditor"
  ]
}

resource "google_service_account" "argocd_management_identity" {
  project     = module.project.project_id
  account_id  = var.argo_cd_management_identity
  description = "Service Account for the ArgoCD management cluster."
}

resource "google_project_iam_binding" "argocd_management_identity_permissions" {
  for_each = toset(local.argocd_identity_roles)
  project  = module.project.project_id
  role     = each.value
  members = [
    "serviceAccount:${google_service_account.argocd_management_identity.email}"
  ]
}

resource "google_project_iam_member" "argocd_management_identity_project_permissions" {
  for_each = toset(["roles/container.admin"])
  member   = "serviceAccount:${google_service_account.argocd_management_identity.email}"
  project  = module.project.project_id
  role     = each.value
}

resource "google_service_account_iam_member" "gsa_ksa_impersonation" {
  for_each = toset([
    "serviceAccount:${module.project.project_id}.svc.id.goog[argocd/argocd-server]",
    "serviceAccount:${module.project.project_id}.svc.id.goog[argocd/argocd-application-controller]"
  ])
  member             = each.value
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.argocd_management_identity.id

  depends_on = [
    module.argocd_management_cluster
  ]
}