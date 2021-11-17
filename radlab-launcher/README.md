# RAD Lab Launcher

The RAD Lab Launcher will guide you through the process of launching modules in your Google Cloud environment.  

## Installation

1. [Download](https://github.com/GoogleCloudPlatform/rad-lab/archive/refs/heads/main.zip) the content to your local machine. Alternatively, you can check it out directly into Google Cloud Shell by clicking the button below. NOTE: You will need to follow [these steps](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to set up a GitHub Personal Access Token.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)


NOTE: If you are using Windows OS make sure to deploy from `Command Prompt and Run as Adminstrator`.

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

7. To launch infrastructure in Google Cloud, a user must have the appropriate [IAM](https://cloud.google.com/iam/docs/overview) permissions. Each [module](../../modules)'s `README.md` will list the permissions needed to launch the infrastructure. You can use the Google Cloud Console to [view](https://cloud.google.com/iam/docs/manage-access-other-resources) or [change](https://cloud.google.com/iam/docs/manage-access-other-resources#single-role) IAM permissions.

8. The following information about your Google Cloud Platform (GCP) environment is typically needed to launch RAD Lab modules:

   * [Organization ID](https://cloud.google.com/resource-manager/docs/creating-managing-organization#retrieving_your_organization_id)
   * [Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) for RAD Lab deployments (projects/resources).
   * [OPTIONAL] [Folder ID](https://cloud.google.com/resource-manager/docs/creating-managing-folders#view) to deploy the module in an existing folder.
   * [OPTIONAL] [Cloud Storage Bucket](https://cloud.google.com/storage/docs/creating-buckets) with read/write access to save the Terraform state. This bucket is used to save state for all active deployments. 
   
   
   The launcher can create one for you if you do not have one already.

9. Set the default project id where the GCS bucket exists, to store Terraform configs/state. You can use [gcloud config set](https://cloud.google.com/sdk/gcloud/reference/config/set) with project property to set the project.

```
gcloud config set project <myProject>
```

NOTE: If the default project id is not set then in the guided setup you will need to manually enter the GCS bucket name (you would like to create) where you would like to store Terraform configs/state for RAD Lab configs and also the project ID where the GCS bucket will be created.

## Deploy a RAD Lab Module
**If you encounter errors during deployment, please see [Troubleshooting Common Problems](../../docs/TROUBLESHOOTING.md) section for a list of common problems and fixes.**  If you don't see a solution listed, please create an [Issue](https://github.com/GoogleCloudPlatform/rad-lab/issues). 


1. Navigate to the RAD Lab Launcher folder from the main directory:
    ```
    cd ./radlab-launcher/
    ```

2. Start the guided setup:
    ```
    python3 radlab.py
    ``` 

NOTE: Save the **deployment_id** from the output for future reference. It is used to make updates or delete the RAD Lab module deployment.

## Example Launch of Data Science Module

1. Select the RAD Lab modules you would like to deploy

```
List of available RAD Lab modules:
[1] Data Science
[2] Exit
Choose a number for the RAD Lab Module: 
```

2. Select the `Action` you want to perform for the corresponding RAD Lab Model:

```
Action to perform for RAD Lab Deployment ?
[1] Create New
[2] Update
[3] Delete
Choose a number for the RAD Lab Module Deployment Action: 1
```

NOTE: If you are selecting Update/Delete action for RAD Lab Model then you will be required to provide the **deployment id** which is provided as the output of successfully newly created a RAD Lab Module deployment.

```
Enter RAD Lab Module Deployment ID (example 'ioi9' is the id for project with id - radlab-ds-analytics-ioi9):
```
3. If you selected _Create New/Update_ of RAD Lab deployment, follow the guided set up and provide user inputs like - Organization ID, Billing Account, Folder ID, Trusted users for the RAD Lab Module which you are setting up.

4. If you selected _Create New_ of RAD Lab deployment, follow the guided setup and provide the name of the **GCS bucket** and its **Project ID** where you would like to store the terraform deployment state.  Keep in mind you cannot use UPPER case characters, spaces, underscore ** _ ** or contain the word "google". See [Bucket Naming Guidelines](https://cloud.google.com/storage/docs/naming-buckets) for a full list of bucket namming guidelines.

```
Enter the GCS Bucket name where Terraform States will be stored: 
```

NOTE: There should be a Billing associated to the above selected project for the successful creation of the GCS bucket.

5. Enter the `Number of AI Notebooks` required for the specific model.

```
Number of AI Notebooks required [Default is 1 & Maximum is 10] :
```

6. Enter the username of the user whom you would like to provide access to the AI Notebooks.

```
Enter the username of trusted users needing access to AI Notebooks, or enter 'quit': testuser1
Enter the username of trusted users needing access to AI Notebooks, or enter 'quit': quit
```

7. _[Can be Skipped when running on Cloud Shell]_ Set up Application Default Credentials. When you run deployment on cloud shell you see a _Warning_ about using the same credentials as the service credentials associated to the GCE VM where cloud shell is running. If you are using the same _Cloud Admin_ account for RAD Lab deployment with which you have logged in to the cloud shell then you may enter **N** or **n** or **No**, etc.

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

8. _[Can be Skipped when running on Cloud Shell]_ Authenticate as the user of whom you want to have the Application Default Credentials configured to the cloud shell. These credentials should be of the _Cloud Admin_.

   * Follw the link (from the cloud shell terminal) in your browser.

   * Complete the OAuth flow by Authenticating  as _Cloud Admin_ user.

   * Copy the verification code from the browser and paste it on the Cloud Shell terminal waiting for the input.

```
Go to the following link in your browser:  https://accounts.google.com/o/oauth2/auth?....

Enter verification code:
```

9. This is where the Terraform module (example: Data Science module) will kick in and Terraform config scripts will be deployed which will spin up respective projects/services/sources, etc.

10. Once the RAD Lab deployment is completed it will throw the below Outputs on the Cloud Shell Terminal for the _Cloud Admin_ to share with the _RAD Lab users_.

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
