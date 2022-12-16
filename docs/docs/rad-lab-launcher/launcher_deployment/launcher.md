---
sidebar_position: 1
title: Deployment via RAD Lab Launcher
# TODO: See if there's a way to provide icons to steps
---

## Deploy a RAD Lab Module

Below video provides a quick overview on how to setup RAD Lab Launcher and deploy RAD Lab modules with the same.

<iframe
    width="980"
    height="480"
    src="https://www.youtube.com/embed/mHc914BkFkM"
    frameborder="0"
    allow="encrypted-media"
    allowfullscreen
>
</iframe>

**If you encounter errors during deployment, please see [Troubleshooting Common Problems](../troubleshooting.md) section for a list of common problems and fixes.**  If you don't see a solution listed, please create an [Issue](https://github.com/GoogleCloudPlatform/rad-lab/issues). 


1. Navigate to the RAD Lab Launcher folder from the main directory:
    ```bash
    cd ./radlab-launcher/
    ```

2. Start the guided setup:
    ```bash
    python3 radlab.py
    ``` 

:::tip RAD Lab Deployment ID
Save the **deployment_id** from the output for future reference. It is required to supply the deployment id for updating or deleting the RAD Lab module deployments.
:::

## Using Command Line Arguments

RAD Lab Launcher accepts following command line arguments: 

* `--rad-project` or `-p`   : To set Google Cloud Project ID for RAD Lab management.
* `--rad-bucket` or `-b`    : To set GCS Bucket ID under RAD Lab management Google Cloud Project where Terraform states and configs for the modules will be stored.
* `--module` or `-m`        : To select the RAD Lab Module you would like to deploy.
* `--action` or `-a`        : To select the action you would like to perform on the selected RAD Lab module.
* `--varfile` or `-f`       : To pass a file with the key-value pairs of module variables and their default overriden values.
* `--disable-perm-check` or `-dc`       : To disable RAD Lab permissions pre-check. **NOTE:** This doesn't means one will not need the required permissions. This will just disable the permission pre-checks which RAD Lab Launcher do for the module deployments. Thus deployment may still fail eventually if required permissions are not set for the identity spinning up the modules.

_Usage:_

```bash
python3 radlab.py --module <module_name> --action <action_type> --rad-project <projectid> --rad-bucket <bucketid> --varfile <overriding_variables_file>
```
OR
```bash
python3 radlab.py -m <module_name> -a <action_type> -p <projectid> -b <bucketid> -f <overriding_variables_file>
```

## Deployments via Service Account

1. Create a Terraform Service Account in RAD Lab Management Project to execute / deploy the RAD Lab module. Ensure that the Service Account has the above mentioned IAM permissions.

**NOTE:** Make sure to set the `resource_creator_identity` variable to the Service Account ID in `terraform.tfvars` file and pass it in module deployment. Example content of `terraform.tfvars`: 

```bash
resource_creator_identity = <sa>@<projectID>.iam.gserviceaccount.com 
```

1. The User, Group, or Service Account who will be deploying the module should have access to impersonate and grant it the roles, `roles/iam.serviceAccountTokenCreator` on the **Terraform Service Account’s IAM Policy**.

**NOTE:** This is not a Project IAM Binding; this is a **Service Account** IAM Binding.

**NOTE:** Additional [permissions](../launcher_installation/management-project.md#iam-permissions-prerequisites) are required when deploying the RAD Lab modules via [RAD Lab Launcher](../../../category/rad-lab-launcher/). Use `--disable-perm-check` or `-dc` arguments when using RAD lab Launcher for the module deployment.

_Usage:_

```bash
python3 radlab.py --disable-perm-check --varfile /<path_to_file>/<file_with_terraform.tfvars_contents>
```
