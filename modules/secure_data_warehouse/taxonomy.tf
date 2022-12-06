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

  taxonomy_name                   = "secured_taxonomy"
  taxonomy_display_name           = "${local.taxonomy_name}-${local.random_id}"

  confidential_tags = {
    dl = {
      display_name = "US_DL_IDENTIFICATION_DOCUMENT"
      description  = "The driver license identification document."
    }
  }

  private_tags = {
    name = {
      display_name = "FULL_NAME"
      description  = "A full person name, which can include first names, middle names or initials, and last names."
    }
    street = {
      display_name = "STREET"
      description  = "Street Address."
    }
    state = {
      display_name = "STATE"
      description  = "Name of the state."
    }
    email = {
      display_name = "EMAIL"
      description  = "Email ID of the person."
    }
  }

  sensitive_tags = {
    dlid = {
      display_name = "DRIVER_LICENSE_ID"
      description  = "Driver License document ID."
    }
  }
}

resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider                  = google-beta

  project                   = module.project_radlab_sdw_data_govern.project_id
  region                    = var.region
  display_name              = local.taxonomy_display_name
  description               = "Taxonomy created for Sample Sensitive Data"
  activated_policy_types    = ["FINE_GRAINED_ACCESS_CONTROL"]

  depends_on = [
    module.secured_data_warehouse
  ]
}

resource "google_data_catalog_policy_tag" "policy_tag_confidential" {
  provider = google-beta

  taxonomy     = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name = "3_Confidential"
  description  = "Most sensitive data classification. Significant damage to enterprise."
}

resource "google_data_catalog_policy_tag" "confidential_tags" {
  provider = google-beta

  for_each = local.confidential_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "policy_tag_private" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "2_Private"
  description       = "Data meant to be private. Likely to cause damage to enterprise."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_confidential.id
}

resource "google_data_catalog_policy_tag" "private_tags" {
  provider = google-beta

  for_each = local.private_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "policy_tag_sensitive" {
  provider = google-beta

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = "1_Sensitive"
  description       = "Data not meant to be public."
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_private.id
}

resource "google_data_catalog_policy_tag" "sensitive_tags" {
  provider = google-beta

  for_each = local.sensitive_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_sensitive.id
}

resource "google_bigquery_table" "re_id" {
  dataset_id          = "secured_dataset"
  project             = module.project_radlab_sdw_conf_data.project_id
  table_id            = "dl_re_id"
  friendly_name       = "dl_re_id"
  deletion_protection = !var.delete_contents_on_destroy

  schema = templatefile("${path.module}/templates/schema.tpl",
    {
      pt_dl     = google_data_catalog_policy_tag.confidential_tags["dl"].id,
      pt_name   = google_data_catalog_policy_tag.private_tags["name"].id,
      pt_street = google_data_catalog_policy_tag.private_tags["street"].id,
      pt_state  = google_data_catalog_policy_tag.private_tags["state"].id,
      pt_email  = google_data_catalog_policy_tag.private_tags["email"].id,
      pt_dlid   = google_data_catalog_policy_tag.sensitive_tags["dlid"].id
  })

  lifecycle {
    ignore_changes = [
      encryption_configuration # managed by the confidential dataset default_encryption_configuration.
    ]
  }

  depends_on = [
    module.secured_data_warehouse
  ]
}

data "google_bigquery_default_service_account" "bq_sa" {
  project = module.project_radlab_sdw_conf_data.project_id
}

resource "google_data_catalog_taxonomy_iam_binding" "confidential_bq_binding" {
  provider = google-beta

  project  = module.project_radlab_sdw_data_govern.project_id
  taxonomy = google_data_catalog_taxonomy.secure_taxonomy.name
  role     = "roles/datacatalog.categoryFineGrainedReader"
  members = [
    "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}",
    "serviceAccount:${module.secured_data_warehouse.confidential_dataflow_controller_service_account_email}"
  ]
}