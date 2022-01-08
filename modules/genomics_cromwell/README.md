# RAD Lab Genomics-Cromwell Module

## GCP Products/Services 

* Life Sciences API
* Cloud Compute
* CloudSQL
* Cloud Storage
* Virtual Private Cloud (VPC)

## Module Overview 
Cromwell is a Workflow Management System geared towards scientific workflows. Cromwell is open sourced under the BSD 3-Clause license. Checkout Cromwell documentation at https://cromwell.readthedocs.io/

The RAD Lab Genomics module deploys Cromwell server along with a a CloudSQL instance and adds a firewall rule enabling access to the server through IAP Tunnel.

This setup allows you to securely access the cromwell server bu submitting jobs from your device through a secure tunnel without the need to add a public IP to your cromwell server and also access the web UI using your browser through that tunnel.

Once the module is deployed a Storage Bucket will be automtically created that will be used for workflow execution.

The outputs will include the instance name, the project name, the cromwell server instance id, and the service account created. If you are using input files that are not publicly accessible, you will need to give access to the service account.

To create the IAP tunnel on your device, you can run the following command
`gcloud compute start-iap-tunnel <cromwell-vm> 8000 --local-host-port=localhost:8080 --zone=<zone>`
If you are on a Chromebook, note that port 8080 is already mapped to localhost, so you only need to browse to http://localhost:8080 . You can also try accessing the REST API from the CLI, for example to query the workflows you can run 
`curl -X GET “http://localhost:8080/api/workflows/v1/query" -H “accept: application/json”`

to acc

## Reference Architechture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Launcher](../../radlab-launcher/radlab.py).

![](../../docs/images/V4_Genomics_Cromwell.png)


