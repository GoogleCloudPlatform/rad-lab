# RAD Lab Data Science Module

## GCP Products/Services 

* AI Platform Notebooks
* BigQuery
* Cloud Storage
* Virtual Private Cloud (VPC)

## Reference Architecture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Launcher](../../radlab-launcher/radlab.py).

![](../../docs/images/V1_DataScience.png)

## IAM Permissions Prerequisites

Ensure that the identity executing this module has the following IAM permissions, **when creating the project** (`create_project` = true): 
- Parent: `roles/billing.user`
- Parent: `roles/resourcemanager.projectCreator`
- Parent: `roles/orgpolicy.policyAdmin` (OPTIONAL - Only required if setting any Org policy in `modules/[MODULE_NAME]/orgpolicy.tf` as part of RAD Lab module)

When deploying in an existing project, ensure the identity has the following permissions on the project:
- `roles/compute.admin`
- `roles/resourcemanager.projectIamAdmin`
- `roles/iam.serviceAccountAdmin`
- `roles/storage.admin`
- `roles/notebooks.admin`

NOTE: Additional [permissions](./radlab-launcher/README.md#iam-permissions-prerequisites) are required when deploying the RAD Lab modules via [RAD Lab Launcher](./radlab-launcher)

## Using Terraform module
Here are a couple of examples to use the module directly in your Terraform code, as opposed to using the RAD Lab Launcher.

### Simple

```hcl
module "simple" {
  source = "./modules/data_science"

  billing_account_id = "123456-123456-123465"
  organization_id    = "12345678901"
  folder_id          = "1234567890"
}
```
### Use existing project

This example assumes that all the necessary APIs have been enabled as well.

````hcl
module "existing_project" {
  source = "./modules/data_science"

  billing_account_id = "123456-123456-123465"
  organization_id    = "12345678901"
  folder_id          = "1234567890"

  create_project  = false
  project_name    = "ds-project-id"
  enable_services = false
  
  set_external_ip_policy          = false
  set_shielded_vm_policy          = false
  set_trustedimage_project_policy = false
}
````

### Existing network

```hcl
module "existing_project_and_network" {
  source = "./modules/data_science"

  billing_account_id = "123456-123456-123465"
  organization_id    = "12345678901"
  folder_id          = "1234567890"

  create_project  = false
  project_name    = "ds-project-id"
  enable_services = false
  enable_services = false
  
  create_network = false
  network_name   = "data-science-network"
  subnet_name    = "data-science-subnetwork"

  set_external_ip_policy          = false
  set_shielded_vm_policy          = false
  set_trustedimage_project_policy = false
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---: |:---:|:---:|
| billing_account_id | Billing Account associated to the GCP Resources | <code title="">string</code> | ✓ |  |
| *boot_disk_size_gb* | The size of the boot disk in GB attached to this instance | <code title="">number</code> |  | <code title="">100</code> |
| *boot_disk_type* | Disk types for notebook instances | <code title="">string</code> |  | <code title="">PD_SSD</code> |
| *create_network* | If the module has to be deployed in an existing network, set this variable to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *create_project* | Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *enable_services* | Enable the necessary APIs on the project.  When using an existing project, this can be set to false. | <code title="">bool</code> |  | <code title="">true</code> |
| *folder_id* | Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node.  | <code title="">string</code> |  | <code title=""></code> |
| *image_family* | Image of the AI notebook. | <code title="">string</code> |  | <code title="">tf-latest-cpu</code> |
| *image_project* | Google Cloud project where the image is hosted. | <code title="">string</code> |  | <code title="">deeplearning-platform-release</code> |
| *ip_cidr_range* | Unique IP CIDR Range for AI Notebooks subnet | <code title="">string</code> |  | <code title="">10.142.190.0/24</code> |
| *machine_type* | Type of VM you would like to spin up | <code title="">string</code> |  | <code title="">n1-standard-1</code> |
| *network_name* | Name of the network to be created. | <code title="">string</code> |  | <code title="">ai-notebook</code> |
| *notebook_count* | Number of AI Notebooks requested | <code title="">string</code> |  | <code title="">1</code> |
| *organization_id* | Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id | <code title="">string</code> |  | <code title=""></code> |
| *project_name* | Project name or ID, if it's an existing project. | <code title="">string</code> |  | <code title="">radlab-data-science</code> |
| *random_id* | Adds a suffix of 4 random characters to the `project_id` | <code title="">string</code> |  | <code title="">null</code> |
| *set_external_ip_policy* | Enable org policy to allow External (Public) IP addresses on virtual machines. | <code title="">bool</code> |  | <code title="">true</code> |
| *set_shielded_vm_policy* | Apply org policy to disable shielded VMs. | <code title="">bool</code> |  | <code title="">true</code> |
| *set_trustedimage_project_policy* | Apply org policy to set the trusted image projects. | <code title="">bool</code> |  | <code title="">true</code> |
| *subnet_name* | Name of the subnet where to deploy the Notebooks. | <code title="">string</code> |  | <code title="">subnet-ai-notebook</code> |
| *trusted_users* | The list of trusted users. | <code title="set&#40;string&#41;">set(string)</code> |  | <code title="">[]</code> |
| *zone* | Cloud Zone associated to the AI Notebooks | <code title="">string</code> |  | <code title="">us-east4-c</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| deployment_id | RADLab Module Deployment ID |  |
| notebooks-instance-names | Notebook Instance Names |  |
| project-radlab-ds-analytics-id | Analytics Project ID |  |
| user-scripts-bucket-uri | User Script Bucket URI |  |
<!-- END TFDOC -->

## Access RAD Lab Data Science Notebooks

Follow the instructions under [gcp-ai-nootbook-tools Readme](./scripts/usage/README.md).