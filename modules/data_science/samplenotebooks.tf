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


 resource "google_storage_bucket_object" "notebook1" {
  name   = "notebooks/BigQuery_tutorial.ipynb"
  source = "${path.module}/scripts/build/BigQuery_tutorial.ipynb"
  bucket = google_storage_bucket.user_scripts_bucket.name
}

resource "google_storage_bucket_object" "notebook2" {
  name   = "notebooks/Exploring_gnomad_on_BigQuery.ipynb"
  source = "${path.module}/scripts/build/Exploring_gnomad_on_BigQuery.ipynb"
  bucket = google_storage_bucket.user_scripts_bucket.name
}

resource "google_storage_bucket_object" "notebook3" {
  name   = "notebooks/Quantum_Simulation_qsimcirq.ipynb"
  source = "${path.module}/scripts/build/Quantum_Simulation_qsimcirq.ipynb"
  bucket = google_storage_bucket.user_scripts_bucket.name
}

resource "google_storage_bucket_object" "notebook_post_startup_script" {
  name   = "notebooks/startup_script.sh"
  source = "${path.module}/scripts/build/startup_script.sh"
  bucket = google_storage_bucket.user_scripts_bucket.name
}