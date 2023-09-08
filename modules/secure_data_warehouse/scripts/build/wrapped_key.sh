#!/bin/bash

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
#
# Important information for understanding the script:
# https://cloud.google.com/kms/docs/encrypt-decrypt
# https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets

set -ex

terraform_service_account=${1}
key=${2}
secret_name=${3}
project_id=${4}
temporary_crypto_operator_role=${5}
gcloud_impersonate_flag=${6}
exe_path=$(dirname ${0})

key_location=$(echo ${key} |awk -F '/' '{print $4}')
key_name=$(echo ${key} |awk -F '/' '{print $8}')
key_ring=$(echo ${key} |awk -F '/' '{print $6}')

trap 'catch $? $LINENO' EXIT
catch() {
  if    [ "${1}" != "0" ] \
     && [ ${temporary_crypto_operator_role} == "true" ]; then
    echo "Error ${1} occurred on ${2}"
    gcloud kms keys remove-iam-policy-binding ${key_name} --keyring=${key_ring} --location=${key_location} --member=serviceAccount:${terraform_service_account} --role=roles/cloudkms.cryptoOperator --project=${project_id} ${gcloud_impersonate_flag}
  fi
}
generate_wrapped_key() {
    if [ ${temporary_crypto_operator_role} == "true" ]; then
      gcloud kms keys add-iam-policy-binding ${key_name} --keyring=${key_ring} --location=${key_location} --member=serviceAccount:${terraform_service_account} --role=roles/cloudkms.cryptoOperator --project=${project_id} ${gcloud_impersonate_flag}
    fi

    python3 -m pip install --user --upgrade pip

    python3 -m pip install --user virtualenv

    python3 -m venv kms_helper_venv

    # shellcheck source=/dev/null
    source kms_helper_venv/bin/activate

    pip install --upgrade pip

    pip install -r ${exe_path}/wrapped-key/requirements.txt

    response_kms=$(python3 ${exe_path}/wrapped-key/wrapped_key.py --crypto_key_path ${key} --service_account ${terraform_service_account})

    echo "${response_kms}" | \
    gcloud secrets versions add "${secret_name}" \
    --data-file=- \
    --impersonate-service-account="${terraform_service_account}" \
    --project="${project_id}"

    if [ ${temporary_crypto_operator_role} == "true" ]; then
      gcloud kms keys remove-iam-policy-binding ${key_name} --keyring=${key_ring} --location=${key_location} --member=serviceAccount:${terraform_service_account} --role=roles/cloudkms.cryptoOperator --project=${project_id} ${gcloud_impersonate_flag}
    fi
}

generate_wrapped_key