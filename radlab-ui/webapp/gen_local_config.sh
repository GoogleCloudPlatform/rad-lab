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

WEBAPP_DIR=$(pwd)

cd ../automation/terraform/infrastructure

TERRAFORM_DIR=$(pwd)


echo "Retrieving Terraform values ..."
echo ""

cd $TERRAFORM_DIR

TERRAFORM_OUTPUT=$(terraform show -json)

PROJECT_ID=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.project_id.value)
WEBAPP_IDENTITY=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.webapp_identity_email.value)
GOOGLE_CLOUD_ORGANIZATION=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.organization.value)
CREATE_DEPLOYMENT_TOPIC_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.create_topic_name.value)
DELETE_DEPLOYMENT_TOPIC_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.delete_topic_name.value)
ADMIN_GROUP_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.admin_group_name.value)
USER_GROUP_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.user_group_name.value)
MODULE_DEPLOYMENT_BUCKET_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.module_deployment_bucket_name.value)
GITHUB_URL=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.git_repo_url.value)
GITHUB_BRANCH=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.git_repo_branch.value)
GIT_TOKEN_SECRET_KEY_NAME=$(echo "${TERRAFORM_OUTPUT}" | jq -r .values.outputs.git_personal_access_token_secret_id.value)
cd $WEBAPP_DIR

FIREBASE_CONFIG_OUTPUT=$(firebase apps:sdkconfig web --project ${PROJECT_ID} --json)

FIREBASE_API_KEY=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.apiKey)
FIREBASE_AUTH_DOMAIN=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.authDomain)
FIREBASE_PROJECT_ID=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.projectId)
FIREBASE_STORAGE_BUCKET=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.storageBucket)
FIREBASE_MESSAGING_SENDER_ID=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.messagingSenderId)
FIREBASE_APPLICATION_ID=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r .result.sdkConfig.appId)
FIREBASE_MEASUREMENT_ID=$(echo "${FIREBASE_CONFIG_OUTPUT}" | jq -r '.result.sdkConfig.measurementId // empty')

echo "Entering Github configuration ..."
read -p "Github API URL: " GITHUB_API_URL

echo ""

echo "Writing configuration ..."

for ENVIRONMENT in "development" "production"; do
  cat <<EOT > .env.${ENVIRONMENT}.local
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_PUBLIC_API_KEY=${FIREBASE_API_KEY}
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN}
NEXT_PUBLIC_FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID}
NEXT_PUBLIC_FIREBASE_APP_ID=${FIREBASE_APPLICATION_ID}
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID}

# Github Configuration
NEXT_PUBLIC_GIT_URL=${GITHUB_URL}
NEXT_PUBLIC_GIT_BRANCH=${GITHUB_BRANCH}
NEXT_PUBLIC_GIT_API_URL=${GITHUB_API_URL}

# Google Cloud Configuration
NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL=${WEBAPP_IDENTITY}
NEXT_PUBLIC_GCP_PROJECT_ID=${PROJECT_ID}
NEXT_PUBLIC_GCP_ORGANIZATION=${GOOGLE_CLOUD_ORGANIZATION}
NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_TOPIC=${CREATE_DEPLOYMENT_TOPIC_NAME}
NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_DELETE_TOPIC=${DELETE_DEPLOYMENT_TOPIC_NAME}

# User Configuration
NEXT_PUBLIC_RAD_LAB_ADMIN_GROUP=${ADMIN_GROUP_NAME}
NEXT_PUBLIC_RAD_LAB_USER_GROUP=${USER_GROUP_NAME}

# Deployment Configuration
MODULE_DEPLOYMENT_BUCKET_NAME=${MODULE_DEPLOYMENT_BUCKET_NAME}

GIT_TOKEN_SECRET_KEY_NAME=${GIT_TOKEN_SECRET_KEY_NAME}
EOT
done
