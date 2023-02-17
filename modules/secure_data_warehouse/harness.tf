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

    default_apis_data_ingest = [
        "accesscontextmanager.googleapis.com",
        "appengine.googleapis.com",
        "artifactregistry.googleapis.com",
        "bigquery.googleapis.com",
        "cloudbilling.googleapis.com",
        "cloudbuild.googleapis.com",
        "cloudkms.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "cloudscheduler.googleapis.com",
        "compute.googleapis.com",
        "datacatalog.googleapis.com",
        "dataflow.googleapis.com",
        "dlp.googleapis.com",
        "dns.googleapis.com",
        "iam.googleapis.com",
        "pubsub.googleapis.com",
        "serviceusage.googleapis.com",
        "storage-api.googleapis.com"
    ]
    project_services_data_ingest = local.default_apis_data_ingest

    default_apis_data_govern = [
        "accesscontextmanager.googleapis.com",
        "cloudbilling.googleapis.com",
        "cloudkms.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "datacatalog.googleapis.com",
        "dlp.googleapis.com",
        "iam.googleapis.com",
        "serviceusage.googleapis.com",
        "storage-api.googleapis.com",
        "secretmanager.googleapis.com"
    ]

    project_services_data_govern = var.billing_budget_pubsub_topic ? distinct(concat(local.default_apis_data_govern,["pubsub.googleapis.com"])) : local.default_apis_data_govern

    default_apis_non_conf_data = [
        "accesscontextmanager.googleapis.com",
        "bigquery.googleapis.com",
        "cloudbilling.googleapis.com",
        "cloudkms.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "iam.googleapis.com",
        "serviceusage.googleapis.com",
        "storage-api.googleapis.com"
    ]

    project_services_non_conf_data = local.default_apis_non_conf_data

    default_apis_conf_data = [
        "accesscontextmanager.googleapis.com",
        "artifactregistry.googleapis.com",
        "bigquery.googleapis.com",
        "cloudbilling.googleapis.com",
        "cloudbuild.googleapis.com",
        "cloudkms.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "compute.googleapis.com",
        "datacatalog.googleapis.com",
        "dataflow.googleapis.com",
        "dlp.googleapis.com",
        "dns.googleapis.com",
        "iam.googleapis.com",
        "serviceusage.googleapis.com",
        "storage-api.googleapis.com"
    ]

    project_services_conf_data = local.default_apis_conf_data

    project_services_external_flex_template = local.default_apis_external_flex_template

    default_apis_external_flex_template = [
        "cloudresourcemanager.googleapis.com",
        "storage-api.googleapis.com",
        "serviceusage.googleapis.com",
        "iam.googleapis.com",
        "cloudbilling.googleapis.com",
        "artifactregistry.googleapis.com",
        "cloudbuild.googleapis.com",
        "compute.googleapis.com"
    ]

    enable_services = length(local.project_services_data_ingest)> 0 || length(local.project_services_data_govern)> 0 || length(local.project_services_non_conf_data)> 0 || length(local.project_services_conf_data)> 0 ? true : false

    perimeter_additional_members = distinct(concat([
    for i in var.perimeter_additional_members : (
        length(regexall("gserviceaccount.com", "${i}")) > 0 ? "serviceAccount:${i}" : "user:${i}"
    )
    ]))
    projects_ids = {
        data_ingestion   = module.project_radlab_sdw_data_ingest.project_id,
        governance       = module.project_radlab_sdw_data_govern.project_id,
        non_confidential = module.project_radlab_sdw_non_conf_data.project_id,
        confidential     = module.project_radlab_sdw_conf_data.project_id
    }

    secret_name                         = "wrapped_key"
    kek_keyring                         = "kek_keyring_${local.random_id}"
    kek_key_name                        = "kek_key_${local.random_id}"
    key_rotation_period_seconds         = "2592000s" #30 days
    use_temporary_crypto_operator_role  = true

    gcloud_impersonate_flag = length(var.resource_creator_identity) != 0 ? "--impersonate-service-account=${var.resource_creator_identity}" : ""

}

resource "random_id" "default" {
  count       = var.deployment_id == null ? 1 : 0
  byte_length = 2
}

module "project_radlab_sdw_data_ingest" {
  # count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name              = format("%s-data-ingest-%s", var.project_id_prefix, local.random_id) #radlab-sdw-data-ingest-1234
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
  default_service_account = "deprivilege"

  activate_apis = []
}

resource "google_project_service" "enabled_services_data_ingest" {
  for_each                   = toset(local.project_services_data_ingest)
  project                    = module.project_radlab_sdw_data_ingest.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

module "project_radlab_sdw_data_govern" {
  # count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name              = format("%s-data-govern-%s", var.project_id_prefix, local.random_id) #radlab-sdw-data-govern-1234
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
  default_service_account = "deprivilege"

  activate_apis = []
}

resource "google_project_service" "enabled_services_data_govern" {
  for_each                   = toset(local.project_services_data_govern)
  project                    = module.project_radlab_sdw_data_govern.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

module "project_radlab_sdw_conf_data" {
  # count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name              = format("%s-conf-data-%s", var.project_id_prefix, local.random_id) #radlab-sdw-conf-data-1234
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
  default_service_account = "deprivilege"

  activate_apis = []
}

resource "google_project_service" "enabled_services_conf_data" {
  for_each                   = toset(local.project_services_conf_data)
  project                    = module.project_radlab_sdw_conf_data.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

module "project_radlab_sdw_non_conf_data" {
  # count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0"

  name              = format("%s-non-conf-data-%s", var.project_id_prefix, local.random_id) #radlab-sdw-non-conf-data-1234
  random_project_id = false
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id
  org_id            = var.organization_id
  default_service_account = "deprivilege"

  activate_apis = []
}

resource "google_project_service" "enabled_services_non_conf_data" {
  for_each                   = toset(local.project_services_non_conf_data)
  project                    = module.project_radlab_sdw_non_conf_data.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

module "iam_projects" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//test/setup/iam-projects"

  data_ingestion_project_id        = module.project_radlab_sdw_data_ingest.project_id
  non_confidential_data_project_id = module.project_radlab_sdw_non_conf_data.project_id
  data_governance_project_id       = module.project_radlab_sdw_data_govern.project_id
  confidential_data_project_id     = module.project_radlab_sdw_conf_data.project_id
  service_account_email            = var.secure_datawarehouse_service_acccount
  
  depends_on = [
    time_sleep.wait_120_seconds
  ]
}

resource "time_sleep" "wait_60_seconds_projects" {
  create_duration = "60s"

  depends_on = [
    module.iam_projects
  ]
}

# resource "google_project_iam_binding" "remove_owner_role" {
#   for_each = local.projects_ids

#   project = each.value
#   role    = "roles/owner"
#   members = []

#   depends_on = [
#     time_sleep.wait_60_seconds_projects
#   ]
# }

module "template_project" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//test/setup/template-project"

  org_id                = var.organization_id
  folder_id             = var.folder_id
  billing_account       = var.billing_account_id
  location              = var.region
  service_account_email = var.secure_datawarehouse_service_acccount
}

module "kek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id           = module.project_radlab_sdw_data_govern.project_id
  labels               = { environment = "dev" }
  location             = var.region
  keyring              = local.kek_keyring
  key_rotation_period  = local.key_rotation_period_seconds
  keys                 = [local.kek_key_name]
  key_protection_level = "HSM"
  prevent_destroy      = !var.delete_contents_on_destroy

  depends_on = [
    time_sleep.wait_120_seconds
  ]
}

resource "google_secret_manager_secret" "wrapped_key_secret" {
  provider = google-beta

  secret_id = local.secret_name
  labels    = { environment = "dev" }
  project   = module.project_radlab_sdw_data_govern.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on   = [
    time_sleep.wait_120_seconds
  ]
}

resource "null_resource" "wrapped_key" {

  triggers = {
    secret_id = google_secret_manager_secret.wrapped_key_secret.id
  }

  provisioner "local-exec" {
    command = <<EOF
        ${path.module}/scripts/build/wrapped_key.sh \
        ${var.secure_datawarehouse_service_acccount} \
        ${module.kek.keys[local.kek_key_name]} \
        ${google_secret_manager_secret.wrapped_key_secret.name} \
        ${module.project_radlab_sdw_data_govern.project_id} \
        ${local.use_temporary_crypto_operator_role} \
        ${local.gcloud_impersonate_flag}
    EOF
  }

#   depends_on = [
#     google_project_iam_binding.remove_owner_role
#   ]
}

data "google_secret_manager_secret_version" "wrapped_key" {
  project = module.project_radlab_sdw_data_govern.project_id
  secret  = google_secret_manager_secret.wrapped_key_secret.id

  depends_on = [
    null_resource.wrapped_key
  ]
}

module "centralized_logging" {
  source                      = "GoogleCloudPlatform/secured-data-warehouse/google//modules/centralized-logging"
  projects_ids                = local.projects_ids
  logging_project_id          = module.project_radlab_sdw_data_govern.project_id
  kms_project_id              = module.project_radlab_sdw_data_govern.project_id
  bucket_name                 = "bkt-logging-${module.project_radlab_sdw_data_govern.project_id}"
  logging_location            = var.region
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  key_rotation_period_seconds = local.key_rotation_period_seconds

  depends_on = [
    module.iam_projects
  ]
}