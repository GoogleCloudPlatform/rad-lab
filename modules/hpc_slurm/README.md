# HPC - Slurm Cluster

The purpose of this module is to create an HPC cluster with Slurm as the orchestrator. It uses the open source repository maintained by SchedMD to create the HPC cluster. 

## Using Terraform module
Here are a couple of examples to use the module directly in your Terraform code, as opposed to using the RAD Lab Launcher.

### Simple

```hcl
module "simple" {
  source = "./modules/hpc_slurm"
  
  billing_account_id  = "123456-123456-123456"
  organization_id     = "12345678901"
  folder_id           = "1234567890"
}
```

### Use existing project

This example assumes that all the necessary APIs have been enabled and that the identity running the code has the necessary permissions to create the VMs and Firewall rules.

```hcl
module "existing_project" {
  source = "./modules/hpc_slurm"

  billing_account_id  = "123456-123456-123456"
  organization_id     = "12345678901"
  folder_id           = "1234567890"
  
  create_project  = false
  project_id      = "existing-project-id"
  enable_services = false
}
```


<!-- BEGIN TFDOC -->

<!-- END TFDOC -->