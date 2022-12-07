locals {
    secret_name                         = "wrapped_key"
    kek_keyring                         = "kek_keyring_${local.random_id}"
    kek_key_name                        = "kek_key_${local.random_id}"
    key_rotation_period_seconds         = "2592000s" #30 days
    use_temporary_crypto_operator_role  = true

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
        ${var.resource_creator_identity} \
        ${module.kek.keys[local.kek_key_name]} \
        ${google_secret_manager_secret.wrapped_key_secret.name} \
        ${module.project_radlab_sdw_data_govern.project_id} \
        ${local.use_temporary_crypto_operator_role} \
        ${local.gcloud_impersonate_flag}
    EOF
  }

# #   depends_on = [
# #     google_project_iam_binding.remove_owner_role
# #   ]
}

data "google_secret_manager_secret_version" "wrapped_key" {
  project = module.project_radlab_sdw_data_govern.project_id
  secret  = google_secret_manager_secret.wrapped_key_secret.id

  depends_on = [
    null_resource.wrapped_key
  ]
}

module "de_identification_template" {
  source = "GoogleCloudPlatform/secured-data-warehouse/google//modules/de-identification-template"

  project_id                = module.project_radlab_sdw_data_govern.project_id
  terraform_service_account = var.resource_creator_identity
  dataflow_service_account  = module.secured_data_warehouse.dataflow_controller_service_account_email
  crypto_key                = module.kek.keys[local.kek_key_name]
  wrapped_key               = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)
  dlp_location              = var.region
  template_id_prefix        = "de_identification"
  template_file             = "${path.module}/templates/deidentification.tpl"
}