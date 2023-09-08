---
sidebar_position: 3
title: 03 - Infrastructure
---

# Terraform

The `radlab-ui/automation/terraform/infrastructure` folder contains the needed Terraform scripts to set up Google Cloud
necessary to run the RAD Lab UI. Make sure to run all the commands and steps listed here in that folder, unless
indicated otherwise.

:::danger Important
Ensure [01 - Source Control](../source-control) and [02 - Google Cloud](../setup-gcp) steps are complete before
proceeding
:::

## Prerequisites

The following prerequisites have to be met in order to proceed with the Terraform installation.

### IAM Permissions

The identity running the Terraform scripts requires the following permissions at Folder-level, on the Folder where you will create the RAD Lab UI project.

* Project
  Creator ([`roles/resourcemanager.projectCreator`](https://cloud.google.com/resource-manager/docs/access-control-proj#using_predefined_roles))
* Folder IAM
  Admin ([`roles/resourcemanager.folderIamAdmin`](https://cloud.google.com/resource-manager/docs/access-control-folders#FolderRolesAndPermissions))

This will ensure that the RAD Lab UI project can be created and that the service accounts can be
assigned the correct IAM permissions to create the projects (as configured by the RAD Lab modules).

#### Billing

By default, during the installation of the RAD Lab UI, Billing IAM permissions for service accounts have to be set
manually. A Service Account will be created that will orchestrate the creation of Google Cloud projects as part of the
RAD Lab modules. This services
requires [Billing User permissions](https://cloud.google.com/billing/docs/how-to/billing-access#overview-of-cloud-billing-roles-in-cloud-iam)
to link newly created Google Cloud projects to the Billing Account ID.

If the identity running the RAD Lab UI installation
has [Billing Admin permission](https://cloud.google.com/billing/docs/how-to/billing-access#overview-of-cloud-billing-roles-in-cloud-iam)
, you can set `set_billing_permissions` to `true` in your `terraform.tfvars` (more on that later).

### Tools

When installing the RAD Lab UI, a number of tools are required to complete all the steps:

* [`gcloud`](https://cloud.google.com/sdk/docs/install)
* [`npm`](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
* [`firebase-tools`](https://firebase.google.com/docs/cli)
* [`terraform`](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [`jq`](https://stedolan.github.io/jq/download/)

## Infrastructure

### Variable Values

In the `radlab-ui/automation/terraform/infrastructure` folder, create a `terraform.tfvars` file with, at minimum, the
following values (replace the dummy values with the actual values for your organization):

```shell
cd radlab-ui/automation/terraform/infrastructure

cat <<EOT > terraform.tfvars
billing_account_id  = "ABCD12-ABCD12-ABCD12"
parent              = "folders/123456789"
organization_name   = "your-organization-domain"
git_repo_url        = "your-repo-url"
EOT
```

As mentioned earlier, if you want to create the Billing IAM permissions for the RAD Lab modules service account
automatically, set `set_billing_permissions` to `true` in the `terraform.tfvars`-file.

For an overview of which variables can be overridden, please refer to the module's `variables.tf` file. By default, it
will point to the standard public [Git repository](https://github.com/GoogleCloudPlatform/rad-lab) for the rad-lab
modules. If you forked the repo and are hosting your own, make sure that the variable `git_repo_url` is set.

If you want to override other variables, simply add the variable name and the required value to the `terraform.tfvars`
file.

### Initial Run

Run the following commands in a terminal or command window. You can also run this via a CI/CD pipeline if necessary, as
long as the Service Account has the required IAM permissions as described [here](#iam-permissions).

:::warning IMPORTANT
If you receive an error while running `terraform apply` in the next section, run `terraform init -migrate-state` before running `terraform apply -auto-approve`.
:::

```shell
# Setting up GCP Auth
gcloud auth application-default login
gcloud auth login

# Initialise the Terraform modules and providers
terraform init -upgrade

# Run Terraform plan and validate the output
terraform plan -out radlab-ui.out

# Create the resources
terraform apply "radlab-ui.out"

# Init the directory again, as this is required to
#   copy the local state to the newly created storage bucket.
# When prompted, type in 'yes' to copy the local state remotely
terraform init -migrate-state

# Remove the output of the `terraform plan` step
rm -rf radlab-ui.out

# Export PROJECT_ID as environment variable
export PROJECT_ID=$(terraform output -json | jq -r .project_id.value)

# Update your local gcloud config to point to the new project
gcloud config set project ${PROJECT_ID}
```

The reason why you need to run `terraform init` twice is that the Terraform code will create a file (`backend.tf`) with
a `terraform {}` resource, that points to a newly created bucket in the RAD Lab UI project. This will allow you to store
the state remotely and collaborate on any future changes with other developers.

It's important to point out that `terraform.tfvars` contains sensitive information. It's up to you to decide whether you want to store this in Github. If that is not the case, simply don't add that file.

### Github Personal Access Token

To establish a connection between Google App Engine and your Github private repository, you need to generate
a [Github Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
and pass it to Google Cloud's Secret Manager using a `gcloud` command. App Engine can then securely use the secret (Github
Personal Access Token) to fetch the RAD Lab modules from your repo. 

1. To generate the access token, go to [Github.com](https://github.com).  
1. Click on your user profile in the top corner and open Settings
1. Scroll all the way to the bottom and click on `</> Developer Settings`
1. In the **Personal accesss tokens**-section, click on **Generate new token**, underneath **Fine-grained tokens**
1. Enter the following details
   1. Token name: Give it a meaningful name (e.g. `rad-lab-ui`)
   1. Set the expiration date (No expiration is more convenient, but setting a fixed expiration will be more secure)
   1. Underneath **Repository access**, select **Only select repositories** and select the repository where you store the RAD Lab UI code
   1. For **Contents** (underneath **Permissions**), select **Read-Only**
1. Click on **Generate token**
1. Copy the value of the token.

You can add a secret directly on the command line using below command (replace `${GIT_PERSONAL_ACCESS_TOKEN}` with the token copied from the Github UI), where `${PROJECT_ID}` corresponds to the RAD Lab UI project ID. 

```bash
echo -n "${GIT_PERSONAL_ACCESS_TOKEN}" | \
    gcloud secrets versions add $(terraform output -json | jq -r .git_personal_access_token_secret_id.value) --data-file=- --project ${PROJECT_ID}
```

### Connect Repository

:::info NOTE
Make sure to **manually** connect your forked RAD Lab repo before start deploying the RAD Lab modules.
:::

To be able to retrieve the list of available modules, variables and deployment files, Cloud Build requires access to
your repository. This is a step that only has to be executed once. 
1. Open the [Google Cloud console](https://console.cloud.google.com)
2. Navigate to Cloud Build in the newly created project.
3. Go to the Cloud Build > [Triggers](https://console.cloud.google.com/cloud-build/triggers)
4. click on **Connect Repository**. 
5. Follow the necessary steps to connect your repository to the Google Cloud project. 

There is no need to create a trigger in this step, as this has already been done by Terraform.

### Admin API

:::danger Super Admin privileges
The identity that executes this step requires Super Admin permissions. There is no way around this, as
this is how the IAM permissions work for Cloud Identity.  
:::

For the web application to validate group membership, a manual step is required to add the service account to the
correct group. To retrieve the correct service account name, go back to the command line and run the following command.  Copy the output to the clipboard.

```shell
echo "$(terraform show -json | jq -r .values.outputs.webapp_identity_email.value)"
```

1. Go to [https://admin.google.com](https://admin.google.com)
2. Go to the section to manage [roles & permissions](https://admin.google.com/ac/roles)
3. Click on the role **Groups Reader**, which is currently in *BETA*.
4. Click on **Assign Role**
5. Click on **Assign service accounts** and paste the value from the terminal, copied at the start of this section.  

## Billing

:::info IAM Permissions
In order to complete this section, the user executing these steps should have the **Billing Account Admin** role on either the Billing Account or the Google Cloud organization that is linked to the Billing Account.
:::

If you are manually creating the Billing IAM permissions, execute the following steps so the RAD Lab deployment service account can link projects to the billing account.  Make note of the identity name by running the following command.  

```shell
# Retrieve the RAD Lab deployment identity
terraform output -json | jq -r .service_account_module_creator.value
```

### Steps

1. Open the [Google Cloud console](https://console.cloud.google.com)
2. Go to Billing > Manage Billing Accounts
3. Select the Billing Account that you want to use for the RAD Lab deployments
4. Select **Account Management** in the menu 
5. Click on `Show Info Panel` in the top right corner, if it's not already showing
6. Click on **Add Principal**
7. In the text field, add the service account ID that you copied from the terminal at the start of this section
8. In **Role**, select `Billing Account User`.  
9. Click on **+ Add Another Role** and select `Billing Account Costs Manager`
10. Click **Save**

## Organization Policies

Some modules may require changes to organization policies.  This is why we recommend to install the RAD Lab UI in a different folder than the rest of the organization.  You can either set those exceptions at Folder-level, or you can let the UI manage them for you.  If that's the case, you have to grant the service account of the UI the IAM role `roles/orgpolicy.policyAdmin` at **organization**-level.  

Retrieve the ID of the service account by running the following command:
```shell
# Retrieve the RAD Lab deployment identity
terraform output -json | jq -r .service_account_module_creator.value
```

Go back to the [Google Cloud console](https://console.cloud.google.com) and make sure that you select the **organization** at the top of the section.
1. Open the menu and go to **IAM & Admin** > **IAM**
2. Click on **Grant Access**
3. In the section **Add principals**, paste the ID of the service account copied in the previous step.  In **Assign roles**, select **Organization Policy Administrator**
4. Click **Save**

Make sure to select the RAD Lab UI project after this step in the UI.

