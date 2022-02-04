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
# limitations under the License.

PROJECT_ID=$1
REPOSITORY_LOCATION=$2
REPOSITORY_ID=$3

gcloud config set project ${PROJECT_ID}
gcloud builds submit . --config ./scripts/build/container/jupyterlab/cloudbuild.yaml --substitutions _REPOSITORY_LOCATION=$REPOSITORY_LOCATION,_REPOSITORY_ID=$REPOSITORY_ID
