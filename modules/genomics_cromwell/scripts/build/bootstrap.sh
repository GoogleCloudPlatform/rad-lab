#! /bin/bash
 
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


# The following script will download the Cromwell version specified in 
# terraform.tfvars .The script will then copy the updated config file and 
# create a service that will start automatically on reboot


# Check if cromwelly already exists, if so exit
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi


# Install Packages needed
apt-get update
apt-get install -y git wget openjdk-11-jdk
wget https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar
mkdir /opt/cromwell
mv cromwell-${CROMWELL_VERSION}.jar /opt/cromwell/cromwell.jar

# Copy Config and Service files from Bucket
gsutil cp ${BUCKET_URL}/provisioning/cromwell.conf /opt/cromwell/cromwell.conf
gsutil cp ${BUCKET_URL}/provisioning/cromwell.service /etc/systemd/system/cromwell.service

#Delete Config file as no longer needed on the bucket
gsutil rm ${BUCKET_URL}/provisioning/cromwell.conf
gsutil rm ${BUCKET_URL}/provisioning/cromwell.service

# Reload linux daemons and start the service
systemctl daemon-reload
systemctl start cromwell.service

# Make it start automatically with server reboots
systemctl enable cromwell.service

#Run only once
touch /etc/startup_was_launched
