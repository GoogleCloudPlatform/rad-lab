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

# A bash script to create folders with subfolders all in one go.

mkdir -p sample/bigquery-public-data

gsutil cp gs://radlab-solution-bucket/Data_Science_Model/bigquery-public-data/BigQuery_tutorial.ipynb /home/jupyter/sample/bigquery-public-data/BigQuery_tutorial.ipynb
gsutil cp gs://radlab-solution-bucket/Data_Science_Model/bigquery-public-data/Exploring_gnomad_on_BigQuery.ipynb /home/jupyter/sample/bigquery-public-data/Exploring_gnomad_on_BigQuery.ipynb
gsutil cp gs://radlab-solution-bucket/Data_Science_Model/bigquery-public-data/Quantum_Simulation_qsimcirq.ipynb /home/jupyter/sample/bigquery-public-data/Quantum_Simulation_qsimcirq.ipynb

#auto-shutdown script - enable if needed

# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/install.sh
# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/ashutdown.service
# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/ashutdown

# ./install.sh
