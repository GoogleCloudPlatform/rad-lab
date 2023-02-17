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
 
resource "google_project_organization_policy" "domain_restricted_sharing_policy" {
  count      = var.set_domain_restricted_sharing_policy && var.create_budget && var.billing_budget_pubsub_topic ? 1 : 0
  constraint = "iam.allowedPolicyMemberDomains"
  project    = local.project.project_id

  list_policy {
    allow {
      all = true
    }
  }

  depends_on = [
    module.project_radlab_billing_budget
  ]
}

resource "time_sleep" "wait_120_seconds" {
  
  count = (var.set_domain_restricted_sharing_policy && var.create_budget && var.billing_budget_pubsub_topic) || var.enable_services ? 1 : 0

  depends_on = [
      google_project_organization_policy.domain_restricted_sharing_policy,
      google_project_service.enabled_services
      ]

  create_duration = "120s"
}