#!/bin/bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the Lpicense.

set -ex

PROJECT_ID=$1
ZONE=$2
COMPUTE_IMAGE=$3
CONTAINER_IMAGE=$4
NOTEBOOKS_BUCKET=$5

gcloud config set project ${PROJECT_ID}
gcloud builds submit . --config ./scripts/build/cloudbuild.yaml --substitutions "_ZONE=${ZONE},_COMPUTE_IMAGE=${COMPUTE_IMAGE},_CONTAINER_IMAGE=${CONTAINER_IMAGE},_NOTEBOOKS_BUCKET=${NOTEBOOKS_BUCKET}"
