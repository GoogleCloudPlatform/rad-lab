#!/bin/bash

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


#   ___  _____   _   _       _       _                 _
#  / _ \|_   _| | \ | |     | |     | |               | |
# / /_\ \ | |   |  \| | ___ | |_ ___| |__   ___   ___ | | __
# |  _  | | |   | . ` |/ _ \| __/ _ \ '_ \ / _ \ / _ \| |/ /
# | | | |_| |_  | |\  | (_) | ||  __/ |_) | (_) | (_) |   <
# \_| |_/\___/  \_| \_/\___/ \__\___|_.__/ \___/ \___/|_|\_\



export INSTANCE_NAME="AI_NOTEBOOK_INSTANCE_NAME"
export PROJECT="PROJECT_ID"
export LOCATION="ZONE"


function stop_notebook() {
  echo '-----------------------------------------'
  echo '|     Stopping notebook instance         |'
  echo '-----------------------------------------'
  gcloud beta notebooks instances stop $INSTANCE_NAME --location=$LOCATION --format='flattened()'  --project=$PROJECT
  status
}

function start_notebook() {
  banner
  echo ''
  echo ''
  echo '-----------------------------------------'
  echo '|    Starting notebook instance          |'
  echo '-----------------------------------------'
  gcloud beta notebooks instances start $INSTANCE_NAME --location=$LOCATION --format='flattened()'  --project=$PROJECT
  status
}

function status() {
  echo '-----------------------------------------'
  echo '|    Notebook instance Status            |'
  echo '-----------------------------------------'
  gcloud notebooks instances describe $INSTANCE_NAME  --location=$LOCATION --format='table[box,title=\_______O_______/](state:label=notebook_status,machineType.scope(machineTypes),metadata.framework:label=framework,createTime.date('%Y-%m-%d'):label=created)' --project=$PROJECT
  get_url
}

function describe_notebook() {
  echo '-----------------------------------------'
  echo '      Notebook instance Description      |'
  echo '-----------------------------------------'
  gcloud notebooks instances describe $INSTANCE_NAME  --location=$LOCATION --format='flattened()' --project=$PROJECT

}

function get_url() {
  echo '-----------------------------------------'
  echo '|      Jupyter notebook url              |'
  echo '-----------------------------------------'

  proxyUri=$(gcloud notebooks instances describe $INSTANCE_NAME  --location=$LOCATION --format='value(proxyUri)' --project=$PROJECT)
  if [ -z "$proxyUri" ]
  then
    echo ''
    echo " *** No active notebook url found  ***"
    echo ''
  else
    echo ''
    echo "https://$proxyUri"
    echo ''
  fi
}

function print_help() {
  echo '-------------------------------------------------'
  echo '| Script for launching notebook instance on GCP  |'
  echo '-------------------------------------------------'

  echo "configure environmental variables on the script"
  echo ""
  echo "-INSTANCE_NAME                                notebook instance name"
  echo "-LOCATION                                     Google Cloud location of this environment. "
  echo "-PROJECT                                      Google Cloud Project of this environment where notebook instance belong."
}

function banner() {
  echo '  ___  _____   _   _       _       _                 _    '
  echo ' / _ \|_   _| | \ | |     | |     | |               | |   '
  echo '/ /_\ \ | |   |  \| | ___ | |_ ___| |__   ___   ___ | | __'
  echo '|  _  | | |   | .   |/ _ \| __/ _ \  _ \ / _ \ / _ \| |/ /'
  echo '| | | |_| |_  | |\  | (_) | ||  __/ |_) | (_) | (_) |   < '
  echo '\_| |_/\___/  \_| \_/\___/ \__\___|_.__/ \___/ \___/|_|\_\'
}

case "$1" in
    start)
       start_notebook
       ;;
    stop)
       stop_notebook
       ;;
    status)
       status
       ;;
    describe)
       describe_notebook
       ;;
    url)
       get_url
       ;;
    help)
       print_help
       ;;
    *)
       echo "Usage: $0 {start | stop | status | url | describe | help}"
esac

exit 0