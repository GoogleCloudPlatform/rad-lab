# RAD Lab Launcher

The RAD Lab Launcher will guide you through the process of launching modules in your Google Cloud environment.  

## Installation

1. [Download](https://github.com/GoogleCloudPlatform/rad-lab/archive/refs/heads/main.zip) the content to your local machine. Alternatively, you can check it out directly into Google Cloud Shell by clicking the button below. NOTE: You will need to follow [these steps](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to set up a GitHub Personal Access Token.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)


NOTE: If you are using Windows OS make sure to deploy from `Command Prompt and Run as Administrator`.

2. Decompress the download:
   ```
   unzip rad-lab-main.zip
   ```

3. You will need [CURL](https://curl.se/) & [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). These come pre-installed in most linux terminals.

4. Navigate to the  `radlab-launcher` folder:
    ```
    cd ./rad-lab-main/radlab-launcher
    ```

5. Run a script to install the prerequisites:
    ```
    python3 installer_prereq.py
    ```
    _NOTE:_ Currently the deployment is supported for `Python 3.7.3` and above.

    This will install:

    * _[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)_ binary by downloading a pre-compiled binary or compiling it from source.
    * A _[Python module](https://pypi.org/project/python-terraform/)_ which provides a wrapper of terraform command line tool.
    * [Google API Python client library](https://cloud.google.com/apis/docs/client-libraries-explained#google_api_client_libraries) for Google's discovery based APIs.

6. Verify the Terraform installation by running:
    ```
    terraform -help
    ```

    This should produce instructions on running `terraform`. If you get a `command not found` message, there was an error in the installation.    

## Launch Preparation

7. GCP Project for RAD Lab management. (Example - Creating/Utilizing GCS bucket where Terraform states will be stored) 

8. The following information about your Google Cloud Platform (GCP) environment is typically needed to launch RAD Lab modules:

   * [Organization ID](https://cloud.google.com/resource-manager/docs/creating-managing-organization#retrieving_your_organization_id)

   NOTE: If you like to spin up a RAD Lab module in a GCP project without any **Organization**, make sure to disable _orgpolicy.tf_ under `modules/[MODULE-NAME]/` either by manually setting the default value of Orgpolicy variables (example: _set_shielded_vm_policy_ & _set_vpc_peering_policy_ in [app_mod_elastic module](../modules/app_mod_elastic) in _variables.tf_ under `modules/[MODULE-NAME]/` to **false**

   * [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) for RAD Lab deployments (projects/resources).
   * [OPTIONAL] [Folder ID](https://cloud.google.com/resource-manager/docs/creating-managing-folders#view) to deploy the module in an existing folder.
   * [OPTIONAL] [Cloud Storage Bucket](https://cloud.google.com/storage/docs/creating-buckets) with read/write access to save the Terraform state. This bucket is used to save state for all active deployments. The launcher can create one for you if you do not have one already.

### IAM Permissions Prerequisites

In addition to the [module](../modules) specific minimum [IAM](https://cloud.google.com/iam/docs/overview) permissions (listed in Each [module](../modules)'s `README.md`), entity deploying RAD Lab modules via **RAD Lab Launcher** will also need to have below permission:
- Parent: `roles/iam.organizationRoleViewer` [OPTIONAL: This permission is not required if *no parent (organization/folder)* exists]
- RAD Lab Management Project: `roles/storage.admin`
- RAD Lab Management Project: `roles/serviceusage.serviceUsageConsumer`

You can use the Google Cloud Console to [view](https://cloud.google.com/iam/docs/manage-access-other-resources) or [change](https://cloud.google.com/iam/docs/manage-access-other-resources#single-role) IAM permissions.

## Deploy a RAD Lab Module
**If you encounter errors during deployment, please see [Troubleshooting Common Problems](../docs/TROUBLESHOOTING.md) section for a list of common problems and fixes.**  If you don't see a solution listed, please create an [Issue](https://github.com/GoogleCloudPlatform/rad-lab/issues). 


1. Navigate to the RAD Lab Launcher folder from the main directory:
    ```
    cd ./radlab-launcher/
    ```

2. Start the guided setup:
    ```
    python3 radlab.py
    ``` 

NOTE: Save the **deployment_id** from the output for future reference. It is required to supply the deployment id for updating or deleting the RAD Lab module deployment.

### Using Command Line Arguments

RAD Lab launcher accepts following command line arguments: 

* `--rad-project` or `-p`   : To set GCP Project ID for RAD Lab management.
* `--rad-bucket` or `-b`    : To set GCS Bucket ID under RAD Lab management GCP Project where Terraform states & configs for the modules will be stored.
* `--module` or `-m`        : To select the RAD Lab Module you would like to deploy.
* `--action` or `-a`        : To select the action you would like to perform on the selected RAD Lab module.
* `--varfile` or `-f`       : To pass a file with the key-value pairs of module variables and their default overriden values.
* `--disable-perm-check` or `-dc`       : To disable RAD Lab permissions pre-check . NOTE: This doesn't means one will not need the required permissions. This will just disable the permission pre-checks which RAD Lab Launcher do for the module deployments. Thus deployment may still fail eventually if required permissions are not set for the identity spinning up the modules.

_Usage:_

```
python3 radlab.py --module <module_name> --action <action_type> --rad-project <projectid> --rad-bucket <bucketid> --varfile <overriding_variables_file>
```
OR
```
python3 radlab.py -m <module_name> -a <action_type> -p <projectid> -b <bucketid> -f <overriding_variables_file>
```

### Overriding default variables of a RAD Lab Module

To set any module specific variables, use `--varfile` argument while running **radlab.py** and pass a file with variables content. Variables like **organization_id**, **folder_id**, **billing_account_id**, **random_id** (a.k.a. **deployment id**), which are requested as part of guided setup, can be set via --varfile argument by passing them in a file. There is a `terraform.tfvars.example` file under each [module](../modules/) as an example on how can you set/override the default variables.

_Usage :_
```
python3 radlab.py --varfile /<path_to_file>/<file_with_terraform.tfvars_contents>
```

NOTE: When the above argument is not passed then the modules are deployed with module's default variable values in `variables.tf` file.

## Example Launch of Data Science Module

1. Select the RAD Lab modules you would like to deploy

```
List of available RAD Lab modules:
[1] # RAD Lab Application Mordernization Module (w/ Elasticsearch) (app_mod_elastic)
[2] # RAD Lab Data Science Module (data_science)
[3] Exit
Choose a number for the RAD Lab Module: 
```

2. Select the `Action` you want to perform for the corresponding RAD Lab Model:

```
Action to perform for RAD Lab Deployment ?
[1] Create New
[2] Update
[3] Delete
[4] List
Choose a number for the RAD Lab Module Deployment Action: 1
```

NOTE: If you are selecting Update/Delete action for RAD Lab Model then you will be required to provide the **deployment id** which is provided as the output of successfully newly created a RAD Lab Module deployment.

```
Enter RAD Lab Module Deployment ID (example 'ioi9' is the id for project with id - radlab-ds-analytics-ioi9):
```
3. If you selected _Create New/Update_ of RAD Lab deployment, follow the guided set up and provide user inputs like - Organization ID, Billing Account, Folder ID for the RAD Lab Module which you are setting up.

4. If you selected _Create New_ of RAD Lab deployment, follow the guided setup and provide the name of the **GCS bucket** and its **Project ID** where you would like to store the terraform deployment state.  Keep in mind you cannot use UPPER case characters, spaces, underscore ** _ ** or contain the word "google". See [Bucket Naming Guidelines](https://cloud.google.com/storage/docs/naming-buckets) for a full list of bucket namming guidelines.

```
Enter the GCS Bucket name where Terraform States will be stored: 
```

NOTE: There should be a Billing associated to the above selected project for the successful creation of the GCS bucket.

5. This is where the Terraform RAD Lab module (example: Data Science module) will kick in and Terraform config scripts will be deployed which will spin up respective projects/services/sources, etc.

6. Once the RAD Lab deployment is completed it will throw the below Outputs on the Cloud Shell Terminal for the _RAD Lab Admin_ to share with the _RAD Lab users_.

```
Outputs:

deployment_id = "ioi9"
notebooks-instance-names = "notebooks-instance-0"
project-radlab-ds-analytics-id = "radlab-ds-analytics-ioi9"
user-scripts-bucket-uri = "https://www.googleapis.com/storage/v1/b/user-scripts-notebooks-instance-ioi9"


GCS Bucket storing Terrafrom Configs: my-sample-bucket

TERRAFORM DEPLOYMENT COMPLETED!!!
```

NOTE: Save the **deployment_id** for future reference, for making any updates or delete the RAD Lab Module created.

NOTE: If you see any errors on your deployment run please follow the [Troubleshooting doc](../docs/TROUBLESHOOTING.md#rad-lab-troubleshooting) to lookup for errors and corresponding solutions.

## Troubleshooting Common Problems

1. [Project quota exceeded](../docs/TROUBLESHOOTING.md#project-quota-exceeded)
2. [Unable to modify Organization Policy Constraints](../docs/TROUBLESHOOTING.md#google-organization-policies---unable-to-modify-constraints)
3. [Local Terraform Deployment ID Directory Already Exists](../docs/TROUBLESHOOTING.md#local-terraform-deployment-id-directory-already-exists)
4. [Timeout when Destroying the deployment](../docs/TROUBLESHOOTING.md#timeout-when-destroying-the-deployment)
