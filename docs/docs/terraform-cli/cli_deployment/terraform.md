---
sidebar_position: 1
title: Deployment via Terraform commands
# TODO: See if there's a way to provide icons to steps
---

# Deployment via Terraform commands

Navigate to the specific [module](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules) directory which you are planning to deploy and follow below steps:

## Setup Terraform Backend

By default, Terraform stores [state](https://www.terraform.io/docs/state/) locally in a file named `terraform.tfstate`. This default configuration can make Terraform usage difficult for teams when multiple users run Terraform at the same time and each machine has its own understanding (i.e. state file) of the current infrastructure.

To help you avoid such issues, configure a [remote state](https://www.terraform.io/docs/state/remote.html) that points to a Cloud Storage bucket. Remote state is a feature of [Terraform backends](https://www.terraform.io/docs/backends). It stores the state as an object in a configurable prefix in a pre-existing bucket on [Google Cloud Storage](https://cloud.google.com/storage/) (GCS). The bucket must exist prior to configuring the backend.

This backend supports [state locking](https://developer.hashicorp.com/terraform/language/state/locking).

:::note
It is highly recommended that you enable [Object Versioning](https://cloud.google.com/storage/docs/object-versioning) on the GCS bucket to allow for state recovery in the case of accidental deletions and human error.
:::



### Example Configuration

Create a file add the following text to a new Terraform configuration file called `backend.tf`.

```bash
terraform {
    backend "gcs" {
        bucket  = "TF_STATE_BUCKET"
        prefix  = "PATH_TO_GCS_FOLDER"
    }
}
```

`TF_STATE_BUCKET`: [GCS Bucket ID](../cli_installation/setup-gcp.md#gcs-bucket-for-terraform-state) to store Terraform state.

`PATH_TO_GCS_FOLDER`: Path to folders/sub-folders within _TF_STATE_BUCKET_.


## Deploy a RAD Lab Module

Execute below commands in the same order to deploy the module:

```bash
# Initialise the Terraform codebase
terraform init -upgrade -reconfigure

# Create the necessary resources
terraform apply -auto-approve
```

:::tip RAD Lab Deployment ID
Save the **deployment_id** from the output for future reference. It is required to supply the deployment id for updating or deleting the RAD Lab module deployment.
:::
