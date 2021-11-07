# RAD Lab Application Mordernization Module (w/ Elastic Search) 

This module allows the user to create an Elastic Search cluster, deployed on a GKE cluster in Google Cloud Platform.  It follows the [Quickstart-tutorial](https://www.elastic.co/guide/en/cloud-on-k8s/1.8/index.html) available on https://elastic.co.   

## GCP Products/Services 

* Google Kubernetes Engine
* Virtual Private Cloud (VPC)

## Prerequisites

Ensure that the identity executing this module has the following IAM permissions, **when creating the project** (`create_project` = true): 
- Parent: `roles/resourcemanager.projectCreator`
- Project: `roles/compute.admin`

When deploying in an existing project, ensure the identity has the following permissions on the project:
- `roles/compute.admin`
- `roles/container.admin`
- `roles/logging.admin`
- `roles/monitoring.admin`
- `roles/iam.serviceAccountAdmin`
- `roles/iam.serviceAccountUser`
- `roles/resourcemanager.projectIamAdmin`
- `roles/serviceusage.serviceUsageAdmin`

Also ensure that the identity creating the resources has access to a billing account, via `roles/billing.user`.

## Reference Architechture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Installer](../../radlab-installer/radlab.py).

### Deploy Elastic Search
The module deploys both the ECK CRDs and Operators.  As this module can be used to demo Elastic Search, it also deploys an ES and Kibana pod in the cluster.  This behaviour can be switched off by setting `deploy_elastic_search` to false.  This will only deploy the CRDs and Operators.

## Access Elastic Search 

It's currently not possible to run `kubectl port-forward` and access it via the web preview **in Cloud Shell**.  The commands below have to be run from a local terminal instead.  If you use the RAD Lab installer from Cloud Shell, you will have to execute the following commands in a terminal on your local machine.  Make sure that you are logged in with the same user locally, as the one you used to run the installer.  You can do this by running `gcloud auth login`.

```shell
# Retrieve credentials to query the Kubernetes API server.  Replace REGION and PROJECTID with the actual values.  You can copy/paste this command from the Terraform output.
gcloud container clusters get-credentials elastic-search-cluster --region REGION --project PROJECTID

# Check status Elastic Search. The health column should show status green.  Takes around 5 minutes to complete 
kubectl get elasticsearch -n elastic-search-demo

# Check status Kibana.  The health column should show status green.  It can take a while for the pod to become available.
kubectl get kibana -n elastic-search-demo

# Retrieve password
kubectl get secret elastic-search-es-elastic-user -n elastic-search-demo -o go-template='{{.data.elastic | base64decode}}'

# Start port-forwarding tunnel
kubectl port-forward -n elastic-search-demo service/kibana-kb-http 5601

# Open a browser window and point it to https://localhost:5601. Login with username elastic and the password copied from the command above.
```

### Using Terraform module
Here are a couple of examples to directly use the Terraform module, as opposed to using the RAD Lab installer.

#### Simple

```hcl
module "elastic_search_simple" {
  source = "./app_mod_elastic"

  billing_account_id = "123456-123456-123456"
  organization_id    = "12345678901"
  folder_id          = "1234567890"
}
```

#### Use existing project
Replace `pref-project-id` with an existing project ID.
```hcl
module "elastic_search_project" {
  source = "./app_mod_elastic"

  billing_account_id = "123456-123456-123456"
  organization_id    = "12345678901"
  folder_id          = "1234567890"
  create_project     = false
  project_name       = "pref-project-id"
}
```

#### Use existing network
Both the project and the network has to exist already for this to work.  Additionally, if all the resources for egress traffic have already been created, set `enable_internet_egress_traffic` to **false**.  
```hcl
module "elastic_search_project" {
  source = "./app_mod_elastic"

  billing_account_id = "123456-123456-123456"
  organization_id    = "12345678901"
  folder_id          = "1234567890"
  create_project     = false
  project_name       = "pref-project-id"
  create_network     = false
  network_name       = "network-name"
  subnet_name        = "subnet-name"
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---: |:---:|:---:|
| billing_account_id | Billing account ID that will be linked to the project. | <code title="">string</code> | ✓ |  |
| organization_id | Organization ID where the project will be created. | <code title="">string</code> | ✓ |  |
| *folder_id* | Folder ID where the project should be created.  Leave blank if the project should be created directly underneath the Organization node. | <code title="">string</code> |  | <code title=""></code> |
| *gke_cluster_name* | Name that will be assigned to the GKE cluster. | <code title="">string</code> |  | <code title="">elastic-search-cluster</code> |
| *master_ipv4_cidr_block* | IPv4 CIDR block to assign to the Master cluster. | <code title="">string</code> |  | <code title="">10.200.0.0/28</code> |
| *network_cidr_block* | CIDR block to be assigned to the network | <code title="">string</code> |  | <code title="">10.0.0.0/16</code> |
| *network_name* | Name to be assigned to the network hosting the GKE cluster. | <code title="">string</code> |  | <code title="">elastic-search-nw</code> |
| *node_pool_machine_type* | Machine type for the node pool. | <code title="">string</code> |  | <code title="">e2-medium</code> |
| *node_pool_name* | Name of the nodepool. | <code title="">string</code> |  | <code title="">elastic-search-pool</code> |
| *pod_cidr_block* | CIDR block to be assigned to pods running in the GKE cluster. | <code title="">string</code> |  | <code title="">10.100.0.0/16</code> |
| *project_name* | Name that will be assigned to the project.  To ensure uniqueness, a random_id will be added to the name. | <code title="">string</code> |  | <code title="">elastic-search-demo</code> |
| *random_id* | Random ID that will be used to suffix all resources.  Leave blank if you want to module to use a generated one. | <code title="">string</code> |  | <code title="">null</code> |
| *region* | Region where the resources should be created. | <code title="">string</code> |  | <code title="">us-west1</code> |
| *service_cidr_block* | CIDR block to be assigned to services running in the GKE cluster. | <code title="">string</code> |  | <code title="">10.150.0.0/16</code> |
| *subnet_name* | Name to be assigned to the subnet hosting the GKE cluster. | <code title="">string</code> |  | <code title="">elastic-search-snw</code> |

## Outputs

<!-- END TFDOC -->