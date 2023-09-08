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

provider "google" {
  alias = "impersonated"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
}

data "google_service_account_access_token" "default" {
  count                  = length(var.resource_creator_identity) != 0 ? 1 : 0
  provider               = google.impersonated
  scopes                 = ["userinfo-email", "cloud-platform"]
  target_service_account = var.resource_creator_identity
  lifetime               = "1800s"
}

provider "google" {
  access_token = length(var.resource_creator_identity) != 0 ? data.google_service_account_access_token.default[0].access_token : null
}

provider "google-beta" {
  access_token = length(var.resource_creator_identity) != 0 ? data.google_service_account_access_token.default[0].access_token : null
}