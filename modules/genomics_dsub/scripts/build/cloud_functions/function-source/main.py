#!/usr/bin/env python3

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

import subprocess
import os

def ngs_qc_trigger(event, context):

    """
    Cloud function that uses dsub (https://github.com/DataBiosphere/dsub) to execute
    pipeline jobs using lifesciences api in GCP.

    GCS EVENT TRIGGER:
    Triggered by a change to a Cloud Storage bucket.
    Function is triggered when a (e.g Fastq) file is added to a GCS bucket.
    The trigger event and bucket to be selected during the function creation

    Requirements.txt:
    dsub is included in the requirements.txt and gets installed through pip

    Python libraries:
    function executes dsub as a python subprocess. The function uses subprocess packaged already with python 3.8

    Args:
    To be defined: GCP_PROJECT,GCS_INPUT_BUCKET,GCS_OUTPUT_BUCKET,GCS_LOG_LOCATION,CONTAINER_IMAGE
    Based on the file events, variables around file name, path and bucket information are pulled from the event info
    """

    file = event
    GCS_INPUT_BUCKET = file['bucket']
    GCS_INPUT_FASTQ_FILE = file['name']

    GCP_PROJECT = os.environ.get('GCP_PROJECT', 'Project id not set')
    GCS_OUTPUT_BUCKET = os.environ.get('GCS_OUTPUT_BUCKET', 'Output GCS bucket not set')
    GCS_LOG_LOCATION = os.environ.get('GCS_OUTPUT_BUCKET', 'log GCS bucket not set')
    CONTAINER_IMAGE = os.environ.get('CONTAINER_IMAGE', 'Unable to find container image')
    REGION = os.environ.get('REGION', 'Region for lifesciences api not set')
    NETWORK = os.environ.get('NETWORK', 'NETWORK for lifesciences api not set')
    SUBNETWORK = os.environ.get('SUBNETWORK', 'SUBNETWORK for lifesciences api not set')
    ZONES =os.environ.get('ZONES', 'ZONES for lifesciences api not set')
    DISK_SIZE =os.environ.get('DISK_SIZE', 'ZONES for lifesciences api not set')
    SERVICE_ACCOUNT = os.environ.get('SERVICE_ACCOUNT','NGS Service Account not set')

    print(f"Processing fastq file: {GCS_INPUT_FASTQ_FILE}.")
    print(file)

    dsub_params = f"dsub --provider google-cls-v2 --project {GCP_PROJECT} --network {NETWORK} --subnetwork {SUBNETWORK} --disk-size {DISK_SIZE} --logging {GCS_LOG_LOCATION} --location {REGION} --zones {ZONES} --input FASTQ=gs://{GCS_INPUT_BUCKET}/{GCS_INPUT_FASTQ_FILE} --output HTML={GCS_OUTPUT_BUCKET}/*  --image {CONTAINER_IMAGE} --service-account {SERVICE_ACCOUNT} "
    fastq_cmd = "--command 'fastqc ${FASTQ} --outdir=$(dirname ${HTML})' --enable-stackdriver-monitoring"
    cmd = dsub_params + fastq_cmd
    print(cmd)
    p = subprocess.run(cmd, shell=True)
    print(p)
