#!/bin/bash

# Copyright 2023 Google LLC
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
# limitations under the License.

# PROJECT_ID=$1

# gcloud config set project ${PROJECT_ID}
# gcloud builds submit . --config ./scripts/build/container/fastqc-0.11.9a/cloudbuild.yaml



PROJECT_ID=$1
SERVICE_ACCOUNT=$2

if [ -n "${SERVICE_ACCOUNT}" ] 
then
    echo "SERVICE_ACCOUNT is set to a non-empty string"
    gcloud config set project ${PROJECT_ID} --impersonate-service-account=${SERVICE_ACCOUNT}
    gcloud builds submit . --config ./scripts/build/container/fastqc-0.11.9a/cloudbuild.yaml --impersonate-service-account=${SERVICE_ACCOUNT}
else
    echo "SERVICE_ACCOUNT is set to an empty string"
    gcloud config set project ${PROJECT_ID}
    gcloud builds submit . --config ./scripts/build/container/fastqc-0.11.9a/cloudbuild.yaml
fi
