#!/usr/bin/env bash
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROJECT_ID=$1
TERRAFORM_VERSION=$2
TERRAFORM_CHECKSUM=$3
IMAGE_NAME=$4

gcloud config set project ${PROJECT_ID}
gcloud builds submit . --config cloudbuild.yaml --substitutions _TERRAFORM_VERSION=${TERRAFORM_VERSION},_TERRAFORM_VERSION_SHA256SUM=${TERRAFORM_CHECKSUM},_IMAGE_NAME=${IMAGE_NAME}
