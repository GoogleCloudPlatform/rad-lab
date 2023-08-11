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
  emails = length(var.trusted_users) > 0 ? distinct(concat(tolist(var.billing_budget_notification_email_addresses), formatlist(tolist(var.trusted_users)[0]))) : tolist(var.billing_budget_notification_email_addresses)
}

resource "google_monitoring_notification_channel" "email_notif" {
  count        = var.create_budget ? length(local.emails) : 0 
  display_name = "Billing Budget Notification Channel - ${element(local.emails, count.index)}"
  project      = local.project.project_id
  type         = "email"
  labels       = {
    email_address = "${element(local.emails, count.index)}"
  }
  
  depends_on   = [
    time_sleep.wait_120_seconds
  ]
}

resource "google_pubsub_topic" "budget_topic" {
  count   = var.billing_budget_pubsub_topic ? 1 : 0
  name    = "budget-topic-${local.project.project_id}"
  project = local.project.project_id
}

resource "google_pubsub_subscription" "budget_topic_subscription" {
  count   = var.billing_budget_pubsub_topic ? 1 : 0
  name    = "${google_pubsub_topic.budget_topic[0].name}-subscription"
  topic   = google_pubsub_topic.budget_topic[0].name
  project = local.project.project_id
}

resource "google_billing_budget" "budget" {
  count = var.create_budget ? 1 : 0

  billing_account = var.billing_account_id
  display_name    = format("Billing Budget - %s", local.project.project_id)

  budget_filter {
    projects               = toset(["projects/${local.project.project_id}"])
    credit_types_treatment = var.billing_budget_credit_types_treatment
    services               = var.billing_budget_services
    labels                 = var.billing_budget_labels
  }

  amount {
    specified_amount {
      units         = tostring(var.billing_budget_amount)
      currency_code = var.billing_budget_amount_currency_code
    }
  }

  dynamic "threshold_rules" {
    for_each = var.billing_budget_alert_spent_percents
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = var.billing_budget_alert_spend_basis
    }
  }

  all_updates_rule {
    disable_default_iam_recipients   = true
    pubsub_topic                     = var.billing_budget_pubsub_topic ? "${google_pubsub_topic.budget_topic[0].id}" : null
    monitoring_notification_channels = length(local.emails) > 0 ? toset(google_monitoring_notification_channel.email_notif[*].name) : []
  }

  depends_on = [
    google_project_service.enabled_services,
    time_sleep.wait_120_seconds
  ]
}