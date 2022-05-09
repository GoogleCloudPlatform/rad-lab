#! /bin/bash
 
# Copyright 2021 Google LLC
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


# The following script will download the latest version of Nextflow.
# The script will then copy the updated config file and 
# create a service that will start automatically on reboot


# Check if the script has run before, if so exit
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi


# Install Packages needed
apt-get update
apt-get install -y git wget openjdk-11-jdk
wget -qO- https://get.nextflow.io | bash
mv ./nextflow /usr/bin/
chmod 777 /usr/bin/nextflow

# Copy Config and Service files from Bucket
gsutil cp ${BUCKET_URL}/provisioning/nextflow.config /etc/nextflow.config

#Delete Config file as no longer needed on the bucket
gsutil rm ${BUCKET_URL}/provisioning/cromwell.conf



#Run only once
touch /etc/startup_was_launched
