# RAD Lab UI Infrastructure

## Prerequisites

- Fork the official [RAD Lab repository](https://github.com/GoogleCloudPlatform/rad-lab) and clone it locally.
- Permissions to install the Cloud Build application in GitHub as described [here](https://cloud.google.com/build/docs/automating-builds/build-repos-from-github). (**Note**: At the moment, only GitHub is supported).
- The necessary permissions to create a project in Google Cloud.

## Installation

```shell
# Step down in the directory that contains the Terraform code
cd radlab-ui/automation/terraform/infrastructure

# Create a terraform.tfvars file. This is the bare minimum, feel free to override any other variables where you see fit
cat <<EOT > terraform.tfvars
billing_account_id = "ABCD-ABCD-ABCD"
parent             = "folders/123456789"
git_repo_url       = "RADLAB_REPO_URL"
EOT

# Initialise the Terraform codebase
terraform init -upgrade -reconfigure

# Create the necessary resources
terraform apply -auto-approve

# Re-initalise the Terraform code.  Answer 'yes' to upload the state file to the newly created storage bucket
terraform init

# Remove 'backend.tf' from .gitignore, as this now has to be stored in Git
grep -v "backend.tf" ../../../../.gitignore > tmpfile && mv tmpfile ../../../../.gitignore

cd ../../../../
echo "\!radlab-ui/automation/terraform/infrastructure/terraform.tfvars" >> .gitignore
echo "\!radlab-ui/automation/terraform/infrastructure/backend.tf" >> .gitignore

# Add all files to Git, including the newly generated backend.tf
git add --all
git commit -m "Initialise the Terraform code for our environment"
git push
```
