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
  pt_confidential = [ for key, value in var.confidential_tags : { "${key}" = "${google_data_catalog_policy_tag.confidential_tags["${key}"].id}" } ]
  pt_private      = [ for key, value in var.private_tags : { "${key}" = "${google_data_catalog_policy_tag.private_tags["${key}"].id}" } ]
  pt_sensitive    = [ for key, value in var.sensitive_tags : { "${key}" = "${google_data_catalog_policy_tag.sensitive_tags["${key}"].id}" } ]
}
resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider                  = google-beta

  project                   = module.project_radlab_sdw_data_govern.project_id
  region                    = var.region
  display_name              = local.taxonomy_display_name
  description               = "Taxonomy created for Sensitive Data"
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

  for_each = var.confidential_tags

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

  for_each = var.private_tags

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

  for_each = var.sensitive_tags

  taxonomy          = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name      = each.value["display_name"]
  description       = each.value["description"]
  parent_policy_tag = google_data_catalog_policy_tag.policy_tag_sensitive.id
}

resource "local_file" "schema_template_file" {
  filename  = format("${path.module}/templates/schema.tpl")
  content   = templatefile("${path.module}/templates/schema_template.tpl",
  {
    fields            = var.data_fields
    confidential_tags = var.confidential_tags
    private_tags      = var.private_tags
    sensitive_tags    = var.sensitive_tags
    pt_confidential   = merge(local.pt_confidential...)
    pt_private        = merge(local.pt_private...)
    pt_sensitive      = merge(local.pt_sensitive...)
  })
}

resource "google_bigquery_table" "re_id" {
  dataset_id          = local.confidential_dataset_id
  project             = module.project_radlab_sdw_conf_data.project_id
  table_id            = local.confidential_table_id
  friendly_name       = local.confidential_table_id
  deletion_protection = !var.delete_contents_on_destroy

  schema = local_file.schema_template_file.content

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
  depends_on = [
    time_sleep.wait_120_seconds
  ]
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