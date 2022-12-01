resource "google_project_iam_member" "role_owner" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_ingest.project_id
  role     = "roles/owner"
}
resource "google_project_iam_member" "role_govern_owner" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_data_govern.project_id
  role     = "roles/owner"
}
resource "google_project_iam_member" "role_conf_data_owner" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_conf_data.project_id
  role     = "roles/owner"
}
resource "google_project_iam_member" "role_non_conf_owner" {
  for_each = toset(concat(formatlist("user:%s", var.owner_users), formatlist("group:%s", var.owner_groups)))
  member   = each.value
  project  = module.project_radlab_sdw_non_conf_data.project_id
  role     = "roles/owner"
}
