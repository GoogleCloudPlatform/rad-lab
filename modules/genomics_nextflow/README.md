# RAD Lab Genomics-Nextflow Module

## GCP Products/Services 

* Life Sciences API
* Batch API
* Cloud Compute
* Cloud Storage
* Virtual Private Cloud (VPC)

## Module Overview 
Nextflow is a bioinformatics workflow manager that enables the development of portable and reproducible workflows. It supports deploying workflows on a variety of execution platforms including local, HPC schedulers, Google Cloud Life Sciences, Google Batch and Kubernetes. Additionally, it provides support for manage your workflow dependencies through built-in support for Conda, Docker. You can read more about Nextflow at [https://www.nextflow.io/docs/latest//](https://www.nextflow.io/docs/latest/)

The RAD Lab Genomics Nextflow module deploys a Nextflow server along with a Service Account and adds a firewall rule enabling access to the server through IAP Tunnel.

This setup allows you to securely access the Nextflow server through a secure tunnel without the need to add a public IP to your Nextflow.

Once the module is deployed a Storage Bucket will be automtically created that will be used for workflow execution.

The outputs will include the instance name, the project name, the nextflow server instance id, the service account created and the GCS Bucket configured for workflow execution. If you are using input files that are not publicly accessible, you will need to give access to the service account.

You can SSH to the Nextflow VM from the console or using the gcloud command in the output. You may need to wait for a few minutes for the installtion to complete, if you can see the RADLAB ascii art when you login, exit and ssh again in a few minutes.

You may recieve an error message the first time you run Nextflow, if this is the case, please update Nextflow by running `nextflow -self-update` then check the version installed by running `nextflow -v`

To test the deployment with Life Sciences API you can try to run
`nextflow -c /etc/nextflow.config run nextflow-io/hello' -profile gls`
And for Batch Api run
`nextflow -c /etc/nextflow.config run nextflow-io/hello' -profile gbatch`


## Reference Architecture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Launcher](../../radlab-launcher/radlab.py).

![](../../docs/images/V1_Nextflow.png)

## IAM Permissions Prerequisites

Ensure that the identity executing this module has the following IAM permissions, **when creating the project** (`create_project` = true): 
- Parent: `roles/billing.user`
- Parent: `roles/resourcemanager.projectCreator`
- Parent: `roles/orgpolicy.policyAdmin` [OPTIONAL - Only required if setting Org Policies via **orgpolicy.tf** for the module]

When deploying in an existing project, ensure the identity has the following permissions on the project:
- `roles/compute.admin`
- `roles/resourcemanager.projectIamAdmin`
- `roles/iam.serviceAccountAdmin`
- `roles/storage.admin`

NOTE: Additional [permissions](./radlab-launcher/README.md#iam-permissions-prerequisites) are required when deploying the RAD Lab modules via [RAD Lab Launcher](./radlab-launcher)

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---: |:---:|:---:|
| billing_account_id | Billing Account associated to the GCP Resources | <code title="">string</code> | ✓ |  |
| *create_network* | If the module has to be deployed in an existing network, set this variable to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *create_project* | Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *default_region* | The default region where the Compute Instance and VPCs will be deployed | <code title="">string</code> |  | <code title="">us-central1</code> |
| *default_zone* | The default zone where the Compute Instance be deployed | <code title="">string</code> |  | <code title="">us-central1-a</code> |
| *enable_services* | Enable the necessary APIs on the project.  When using an existing project, this can be set to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *folder_id* | Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node.  | <code title="">string</code> |  | <code title=""></code> |
| *ip_cidr_range* | Unique IP CIDR Range for nextflow subnet | <code title="">string</code> |  | <code title="">10.142.190.0/24</code> |
| *network_name* | This name will be used for VPC created | <code title="">string</code> |  | <code title="">nextflow-vpc</code> |
| *nextflow_API_location* | Google Cloud region or multi-region where the Life Sciences API endpoint will be used. This does not affect where worker instances or data will be stored. | <code title="">string</code> |  | <code title="">us-central1</code> |
| *nextflow_sa_roles* | List of roles granted to the nextflow service account. This server account will be used to run both the nextflow server and workers as well. | <code title="list&#40;any&#41;">list(any)</code> |  | <code title="&#91;&#10;&#34;roles&#47;lifesciences.workflowsRunner&#34;,&#10;&#34;roles&#47;serviceusage.serviceUsageConsumer&#34;,&#10;&#34;roles&#47;storage.objectAdmin&#34;,&#10;&#34;roles&#47;batch.jobsAdmin&#34;,&#10;&#34;roles&#47;batch.agentReporter&#34;,&#10;&#34;roles&#47;iam.serviceAccountUser&#34;,&#10;&#34;roles&#47;browser&#34;,&#10;&#34;roles&#47;logging.viewer&#34;&#10;&#93;">...</code> |
| *nextflow_server_instance_name* | Name of the VM instance that will be used to deploy nextflow Server, this should be a valid Google Cloud instance name. | <code title="">string</code> |  | <code title="">nextflow-server</code> |
| *nextflow_server_instance_type* | nextflow server instance type | <code title="">string</code> |  | <code title="">e2-standard-4</code> |
| *nextflow_zone* | GCP Zone that will be set as the default runtime in nextflow config file. | <code title="">string</code> |  | <code title="">us-central1-a</code> |
| *organization_id* | Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id | <code title="">string</code> |  | <code title=""></code> |
| *project_name* | Project name or ID, if it's an existing project. | <code title="">string</code> |  | <code title="">radlab-genomics-nextflow</code> |
| *random_id* | Adds a suffix of 4 random characters to the `project_id` | <code title="">string</code> |  | <code title="">null</code> |
| *set_external_ip_policy* | If true external IP Policy will be set to allow all | <code title="">bool</code> |  | <code title="">false</code> |
| *set_restrict_vpc_peering_policy* | If true restrict VPC peering will be set to allow all | <code title="">bool</code> |  | <code title="">true</code> |
| *set_shielded_vm_policy* | If true shielded VM Policy will be set to disabled | <code title="">bool</code> |  | <code title="">true</code> |
| *set_trustedimage_project_policy* | If true trusted image projects will be set to allow all | <code title="">bool</code> |  | <code title="">true</code> |
| *subnet_name* | This name will be used for subnet created | <code title="">string</code> |  | <code title="">nextflow-vpc</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| GCS_Bucket_URL | Google Cloud Storage Bucket configured for workflow execution |  |
| gcloud_ssh_command | To connect to the Nextflow instance using Identity Aware Proxy, run the following command |  |
| nextflow_server_instance_id | VM instance name running the nextflow server |  |
| nextflow_server_zone | Google Cloud zone in which the server was provisioned |  |
| nextflow_service_account_email | Email address of service account running the server and worker nodes |  |
| project_id | Project ID where resources where created |  |
<!-- END TFDOC -->