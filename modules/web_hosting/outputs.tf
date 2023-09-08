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


output "billing_budget_budget_id" {
  sensitive   = true
  description = "Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}`"
  value       = var.create_budget ? google_billing_budget.budget[0].name : ""
}

output "deployment_id" {
  description = "RAD Lab Module Deployment ID"
  value       = local.random_id
}

output "project_id" {
  description = "Web Hosting RAD Lab Project ID"
  value       = local.project.project_id
}

output "lb_content_based" {
  description = "URLs to Content Based Load Balancer"
  value = concat(formatlist("http://%s:80", google_compute_global_forwarding_rule.fe_http_content_based.ip_address),
    formatlist("http://%s:80/create", google_compute_global_forwarding_rule.fe_http_content_based.ip_address),
  formatlist("http://%s:80/delete", google_compute_global_forwarding_rule.fe_http_content_based.ip_address))
}

output "lb_region_based" {
  description = "URL to Region Based Load Balancer"
  value       = formatlist("http://%s:80", google_compute_global_forwarding_rule.fe_http_cross_region_cdn.ip_address)
}

output "lb_region_based_cdn_gcs" {
  description = "URL to Region Based Load Balancer with Cloud Storage Static Objects with CDN"
  value       = formatlist("http://%s:80/%s", google_compute_global_forwarding_rule.fe_http_cross_region_cdn.ip_address, google_storage_bucket_object.picture.name)
}