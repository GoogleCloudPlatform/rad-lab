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

set -ex

PROJECT_ID=$1
AH_PROJECT_ID=$2
AH_DATA_EXCHANGE_ID=$3
AH_LISTING_ID=$4
AH_LINKED_DATASET=$5
SERVICE_ACCOUNT=$6
TOKEN=$7

if [ -n "${SERVICE_ACCOUNT}" ] 
then
    curl --request POST \
    "https://analyticshub.googleapis.com/v1/projects/${AH_PROJECT_ID}/locations/us/dataExchanges/${AH_DATA_EXCHANGE_ID}/listings/${AH_LISTING_ID}:subscribe" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "x-goog-user-project: ${PROJECT_ID}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    --data "{\"destinationDataset\":{\"datasetReference\":{\"datasetId\":\"${AH_LINKED_DATASET}\",\"projectId\":\"${PROJECT_ID}\"},\"location\":\"US\"}}" \
    --compressed
else
    curl --request POST \
    "https://analyticshub.googleapis.com/v1/projects/${AH_PROJECT_ID}/locations/us/dataExchanges/${AH_DATA_EXCHANGE_ID}/listings/${AH_LISTING_ID}:subscribe" \
    -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    -H "x-goog-user-project: ${PROJECT_ID}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    --data "{\"destinationDataset\":{\"datasetReference\":{\"datasetId\":\"${AH_LINKED_DATASET}\",\"projectId\":\"${PROJECT_ID}\"},\"location\":\"US\"}}" \
    --compressed
fi