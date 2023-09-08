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
  parent_deployment_folder      = var.module_deployment_folder != null ? var.module_deployment_folder : var.parent
  radlab_module_billing_account = var.module_deployment_billing_account == null ? var.billing_account_id : var.module_deployment_billing_account

  bool_org_policy = var.disable_require_vpc_egress_connector_org_policy ? {
    "constraints/cloudfunctions.requireVPCConnector" = false
  } : {}
}

module "project" {
  source             = "../modules/project"
  parent             = var.parent
  project_name       = var.project_name
  billing_account_id = var.billing_account_id
  lien_reason        = "RAD Lab UI project, shouldn't be deleted."

  project_apis = [
    "firestore.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "appengine.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "container.googleapis.com",
    "admin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "dataflow.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  org_policy_bool = local.bool_org_policy
}

# Create storage buckets
resource "local_file" "terraform_state_file" {
  filename = "${path.module}/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    TERRAFORM_STATE_BUCKET_NAME = google_storage_bucket.radlab_ui_state_storage.name
    TERRAFORM_STATE_PREFIX      = "tfstate/radlab-ui-project/"
  })
}

resource "google_secret_manager_secret" "git_repo_access_token" {
  project   = module.project.project_id
  secret_id = var.git_repo_access_token

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_member" "ui_git_repo_personal_access_token_access" {
  project   = module.project.project_id
  member    = "serviceAccount:${google_service_account.radlab_ui_webapp_identity.email}"
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.git_repo_access_token.id
}

