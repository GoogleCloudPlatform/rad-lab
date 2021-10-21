# RAD Lab Application Mordernization Module (w/ Elastic Search) 

This module allows the user to create an Elastic Search cluster, deployed on a GKE cluster in Google Cloud Platform.  It follows the [Quickstart-tutorial](https://www.elastic.co/guide/en/cloud-on-k8s/1.8/k8s-quickstart.html) available on https://elastic.co.   

## GCP Products/Services 

* Google Kubernetes Engine
* Virtual Private Cloud (VPC)

## Reference Architechture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Installer](../../scripts/radlab.py).

## Commands
Retrieve the cluster credentials 
```shell
$(terraform show -json | jq -r .values.outputs.cluster_credentials_cmd.value)`
```

ElasticSearch status:
```shell
kubectl get elasticsearch -n elastic-search
```

Kibana status:
```shell
kubectl get kibana -n elastic-search
```

Retrieve Elastic password
```shell
kubectl get secret es-quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' -n elastic-search | base64 --decode; echo
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