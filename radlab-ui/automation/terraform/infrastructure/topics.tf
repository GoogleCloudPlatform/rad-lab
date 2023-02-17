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

# Pub/Sub topic to create and update a RAD Lab module deployment
resource "google_pubsub_topic" "radlab_ui_create" {
  project = module.project.project_id
  name    = "rad-lab-topic-deployments"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_topic_iam_member" "ui_identity_publish_permissions_create_modules" {
  project = module.project.project_id
  member  = "serviceAccount:${google_service_account.radlab_ui_webapp_identity.email}"
  role    = "roles/pubsub.publisher"
  topic   = google_pubsub_topic.radlab_ui_create.id
}

# Pub/Sub topic to delete a RAD Lab module deployment
resource "google_pubsub_topic" "radlab_ui_delete" {
  project = module.project.project_id
  name    = "rad-lab-topic-delete"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_topic_iam_member" "ui_identity_publish_permissions_delete_module" {
  project = module.project.project_id
  member  = "serviceAccount:${google_service_account.radlab_ui_webapp_identity.email}"
  role    = "roles/pubsub.publisher"
  topic   = google_pubsub_topic.radlab_ui_delete.id
}

