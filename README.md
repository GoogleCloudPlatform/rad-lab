# RAD Lab

 # Disclaimer
 This repository provides an opinionated way to set up RAD Lab environment in a secure way using Terraform. End users should review and consider their security posture and requirements and adopt/modify RAD Lab to suit their needs before deployment.

 This is not an officially supported Google product

## Run the sample

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)

## Steps to Install RAD Lab Pre-requisites

1. [Download](https://github.com/GoogleCloudPlatform/rad-lab/archive/refs/heads/main.zip) the Complete directory structure & its files on your **Cloud Shell** or Localhost.

NOTE: Alternatively if you want to deploy using the above **Open in Cloud Shell** button you will need to set up GitHup Personal Access Token following [these steps](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) and skip 1. Enter you GitHib credentials. (Enter your Personal Access Token for the password)

NOTE: RAD Lab deployment is supported only via GCP Cloud Shell, MAC OS, Linux & Windows Operating system. 

NOTE: If you are using Windows OS make sure to deploy from `Command Prompt and Run as Adminstrator`. 

2. Decompress the download: `unzip rad-lab-main.zip`

3. Make sure [CURL](https://curl.se/) & [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) is installed on the operating system from where you are running the deployment. 

NOTE: If you are using Cloud Shell then CURL & BASH comes pre-installed with it, thus you can skip this step.

4. Navigate to the RADLab `scripts` folder : `cd ./rad-lab-main/scripts`

4. Install all the pre-requisites by running : `python3 installer_prereq.py`. _NOTE:_ Currently the deployment is supported for `Python 3.7.3` and above. List of Pre-requisites we are installing in this step:

    * _[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)_ binary by downloading a pre-compiled binary or compiling it from source.
    * A _[Python module](https://pypi.org/project/python-terraform/)_ which provides a wrapper of terraform command line tool.
    * [Google API Python client library](https://cloud.google.com/apis/docs/client-libraries-explained#google_api_client_libraries) for Google's discovery based APIs.

5. Verify the installation by running : `terraform -help`

6. Before start deploying the RAD Lab modules there are few considerations which should be made :

    * The lab need to be deployed by a _Cloud Admin_ who has following GCP roles:
        * `Billing Account User`
        * `Organization Viewer`
        * `Project Owner`
        * `Storage Object Viewer`
        * `Organization Policy Administrator`

    * The _Cloud Admin_ should have the following information handy with them which will be used in the guided setup deployment of the RAD Lab module:
        * GCP [Organization ID](https://cloud.google.com/resource-manager/docs/creating-managing-organization#retrieving_your_organization_id)
        * GCP [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) for RAD Lab deployments (projects/resources).
        * [OPTIONAL] GCP [Folder ID](https://cloud.google.com/resource-manager/docs/creating-managing-folders#view) if you would like to deploy the RAD Lab Deployment within specific GCP folder.
        * [OPTIONAL] GCS Bucket with read/write access where the Terraform states will be saved.
        
        NOTE: If you don’t have the GCS bucket already, you will also get the option to create the same as part of the guided setup.
    * Depending on how your Google Organization is configured and how your Project and Service quotas are set, you can run into errors during deployment. Please see the [Troubleshooting Common Problems](./docs/TROUBLESHOOTING.md) section for a list of common problems and fixes. 
7.  _Cloud Admin_ will also need to set the mandotory variables in `variables.tf` file to set up the infrastructure. Please see the details of each variable below:

    * `zone`
        * A reference to the zone where the machine resides.
        * Pick form list of available zones. 
        * REF: https://cloud.google.com/compute/docs/regions-zones#available
    * `ip_cidr_range`
        * The range of internal addresses that are owned by the subnetwork you create. 
        * For example, 10.0.0.0/8 or 192.168.0.0/16. Ranges must be unique and non-overlapping within a network. 
        * Only IPv4 is supported.
    * `machine_type`
        * A reference to a machine type which defines VM kind.
        * Pick the machine type _(Non-deprecated)_ by running `gcloud compute machine-types list` in cloud shell. 
        * REF: https://cloud.google.com/sdk/gcloud/reference/compute/machine-types/list
    * `boot_disk_type`
        * Possible disk types for notebook instances. 
        * Possible values are `DISK_TYPE_UNSPECIFIED`, `PD_STANDARD`, `PD_SSD`, and `PD_BALANCED`.
    * `boot_disk_size_gb`
        * The size of the boot disk in GB attached to this instance, up to a maximum of 64000 GB (64 TB). 
        * The minimum recommended value is 100 GB. If not specified, this defaults to 100.
        * REF: https://cloud.google.com/compute/docs/disks#introduction

NOTE: `variables.tf` all the defaults. If you would like to override or hardcode any variables, please create the `terraform.tfvars` file and set the variables there under **data_science** folder. 

8. Set the default project id where the GCS bucket exists, to store Terraform configs/state. You can use [gcloud config set](https://cloud.google.com/sdk/gcloud/reference/config/set) with project property to set the project.

```
gcloud config set project <myProject>
```

NOTE: If the default project id is not set then in the guided setup you will need to manually enter the GCS bucket name (you would like to create) where you would like to store Terraform configs/state for RAD Lab configs and also the project ID where the GCS bucket will be created.

## Steps to Install RAD Lab Modules

Currently RAD Lab is only comprised of single module i.e. **Data Science** Module and new modules will be coming out soon.

1. Navigate to the RAD Lab `scripts` folder : `cd ./rad-lab-main/scripts` on your Cloud Shell.

2. Start the Guided setup by running : `python3 radlab.py`

3. Select the RAD Lab modules you would like to deploy

```
List of available RADLab modules:
[1] Data Science
[2] Exit
Choose a number for the RADLab Module: 
```

4. Select the `Action` you want to perform for the corresponding RAD Lab Model:

```
Action to perform for RADLab Deployment ?
[1] Create New
[2] Update
[3] Delete
Choose a number for the RADLab Module Deployment Action: 1
```

NOTE: If you are selecting Update/Delete action for RAD Lab Model then you will be required to provide the **deployment id** which is provided as the output of the RAD Lab Model deployment. 

```
Enter RAD Lab Module Deployment ID (example 'ioi9' is the id for project with id - radlab-ds-analytics-ioi9):
```
5. If you selected _Create New/Update_ of RAD Lab deployment, follow the guided set up and provide user inputs like - Organization ID, Billing Account, Folder ID, Trusted users for the RAD Lab Module which you are setting up.

6. If you selected _Create New_ of RAD Lab deployment, follow the guided setup and provide the name of the **GCS bucket** and its **Project ID** where you would like to store the terraform deployment state.  Keep in mind you cannot use UPPER case characters, spaces, underscore ** _ ** or contain the word "google". See [Bucket Naming Guidelines](https://cloud.google.com/storage/docs/naming-buckets) for a full list of bucket namming guidelines. 

```
Enter the GCS Bucket name where Terraform States will be stored: 
```

NOTE: There should be a Billing associated to the above selected project for the successful creation of the GCS bucket.

7. Enter the `Number of AI Notebooks` required for the specific model.

```
Number of AI Notebooks required [Default is 1 & Maximum is 10] :
```

8. Enter the username of the user whom you would like to provide access to the AI Notebooks.

```
Enter the username of trusted users needing access to AI Notebooks, or enter 'quit': testuser1
Enter the username of trusted users needing access to AI Notebooks, or enter 'quit': quit
```

9. _[Can be Skipped when running on Cloud Shell]_ Set up Application Default Credentials. When you run deployment on cloud shell you see a _Warning_ about using the same credentials as the service credentials associated to the GCE VM where cloud shell is running. If you are using the same _Cloud Admin_ account for RAD Lab deployment with which you have logged in to the cloud shell then you may enter **N** or **n** or **No**, etc. 

NOTE: There wont be any issues if you enter **Y** or **y** or **yes**, etc even if you are using the same accounts as you will again get to authenticate in next step as part of guided set up.

```
You are running on a Google Compute Engine virtual machine.
The service credentials associated with this virtual machine
will automatically be used by Application Default
Credentials, so it is not necessary to use this command.

If you decide to proceed anyway, your user credentials may be visible
to others with access to this virtual machine. Are you sure you want
to authenticate with your personal account?

**Do you want to continue (Y/n)?**
```

10. _[Can be Skipped when running on Cloud Shell]_ Authenticate as the user of whom you want to have the Application Default Credentials configured to the cloud shell. These credentials should be of the _Cloud Admin_. 
   
    * Follw the link (from the cloud shell terminal) in your browser.

    * Complete the OAuth flow by Authenticating  as _Cloud Admin_ user.

    * Copy the verification code from the browser and paste it on the Cloud Shell terminal waiting for the input. 

    ```
    Go to the following link in your browser:

        https://accounts.google.com/o/oauth2/auth?....

    Enter verification code:
    ```

11. This is where the Terraform module (example: Data Science module) will kick in and Terraform config scripts will be deployed which will spin up respective projects/services/sources, etc.

12. Once the RAD Lab deployment is completed it will throw the below Outputs on the Cloud Shell Terminal for the _Cloud Admin_ to share with the _RADLab users_.

```
Outputs:

deployment_id = "ioi9"
notebooks-instance-names = "notebooks-instance-0"
project-radlab-ds-analytics-id = "radlab-ds-analytics-ioi9"
user-scripts-bucket-uri = "https://www.googleapis.com/storage/v1/b/user-scripts-notebooks-instance-ioi9"


GCS Bucket storing Terrafrom Configs: my-sample-bucket

TERRAFORM DEPLOYMENT COMPLETED!!!
```

NOTE: If you see any errors on your deployment run please follow the [Troubleshooting doc](./docs/TROUBLESHOOTING.md#rad-lab-troubleshooting) to lookup for errors and corresponding solutions.

## Access RAD Lab Modules

Follow the instructions under [gcp-ai-nootbook-tools Readme](./scripts/gcp-ai-notebook-tools/README.md).

## Troubleshooting Common Problems

1. [Project quota exceeded](./docs/TROUBLESHOOTING.md#project-quota-exceeded)
2. [Unable to modify Organization Policy Constraints](./docs/TROUBLESHOOTING.md#google-organization-policies---unable-to-modify-constraints)
3. [Local Terraform Deployment ID Directory Already Exists](./docs/TROUBLESHOOTING.md#local-terraform-deployment-id-directory-already-exists)