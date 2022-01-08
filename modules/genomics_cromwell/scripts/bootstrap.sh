#! /bin/bash
 
# The following script will download the Cromwell version specified in 
# terraform.tfvars .The script will then copy the updated config file and 
# create a service that will start automatically on reboot


# Check if cromwelly already exists, if so exit
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi


# Install Packages needed
apt-get update
apt-get install -y git wget openjdk-11-jdk
wget https://github.com/broadinstitute/cromwell/releases/download/${cromwell_version}/cromwell-${cromwell_version}.jar
mkdir /opt/cromwell
mv cromwell-${cromwell_version}.jar /opt/cromwell/cromwell.jar

# Copy Config and Service files from Bucket
gsutil cp ${bucket_url}/provisioning/cromwell.conf /opt/cromwell/cromwell.conf
gsutil cp ${bucket_url}/provisioning/cromwell.service /etc/systemd/system/cromwell.service

# Reload linux daemons and start the service
systemctl daemon-reload
systemctl start cromwell.service

# Make it start automatically with server reboots
systemctl enable cromwell.service

#Run only once
touch /etc/startup_was_launched
