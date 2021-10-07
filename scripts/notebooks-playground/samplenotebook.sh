#!/bin/bash
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
