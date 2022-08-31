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
REPOSITORY_LOCATION=$2
REPOSITORY_ID=$3
NOTEBOOKS_BUCKET=$4
SERVICE_ACCOUNT=$5

if [ -n "${SERVICE_ACCOUNT}" ] 
then
    echo "SERVICE_ACCOUNT is set to a non-empty string"
    gcloud config set project ${PROJECT_ID}
    gcloud builds submit . --config ./scripts/build/cloudbuild.yaml --impersonate-service-account=${SERVICE_ACCOUNT} --substitutions "_REPOSITORY_LOCATION=${REPOSITORY_LOCATION},_REPOSITORY_ID=${REPOSITORY_ID},_NOTEBOOKS_BUCKET=${NOTEBOOKS_BUCKET}"
else
    echo "SERVICE_ACCOUNT is set to an empty string"
    gcloud config set project ${PROJECT_ID}
    gcloud builds submit . --config ./scripts/build/cloudbuild.yaml --substitutions "_REPOSITORY_LOCATION=${REPOSITORY_LOCATION},_REPOSITORY_ID=${REPOSITORY_ID},_NOTEBOOKS_BUCKET=${NOTEBOOKS_BUCKET}"
fi