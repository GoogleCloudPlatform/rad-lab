# RAD Lab

The RAD Lab repository contains a set of modules which allows users to create the necessary infrastructure on Google Cloud Platform for specific use cases.  Infrastructure is created through Terraform where possible, but uses custom install scripts where necessary. 

These modules are bundled together with an installer, written in Python, to create a base configuration for every module.  The purpose of the installer is to allow people without Terraform or scripting knowledge to create the infrastructure in a sandbox environment, to explore the advantages of Google Cloud Platform.  Each module comes with a sample configuration that can be created via the installer.

Teams with experience in Terraform can use the Terraform modules in the [/modules-directory](./modules) directly, to integrate the codebase with their existing infrastructure and CI/CD pipelines and should be able to support more advanced scenarios for the same module.

For any issues, please create an issue in the Issue tracker of the repository, following the provided templates.

## Disclaimer

This is not an officially supported Google product

## Run the samples

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)

## Quick Start

To create a module in your GCP environment, please click on the “Open In Cloud Shell” button at the top of this README.md file.  This will clone the entire repository to Cloud Shell and automatically select the `main`-branch.
    
### Prerequisites
* [gcloud](https://cloud.google.com/sdk/docs/install) SDK version 360.0.0 or higher.
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started) version 1.0 or higher.
* [python](https://www.python.org/downloads/) version 3.7.3 or higher.

Users can run `installer_prereq.py` included in the [radlab-installer scripts directory](./scripts/radlab-installer) to validate these prerequisites and install any missing dependencies. 

### Installer
In order to enable all types of users to run these modules, an installer has been created to install each individual module.  The installer walks the end user through a wizard to create the necessary infrastructure for each module.  More instructions on the installer can be found [here](./scripts/radlab-installer).

### Modules

The modules directory contains Terraform modules that can be integrated in existing CI/CD pipelines.  We recommend creating a fork from this repository and use that as part of your overall workflow to create infrastructure.  We can't guarantee backwards compatibility with every release.

### Permissions

From a Google Cloud perspective, every module requires a set of IAM permissions to run the Terraform code.  The individual modules will list the minimum permissions users require to successfully create the infrastructure. 

As a minimum, users should have access to a billing account when creating projects, via the IAM role `roles/billing.user`.  Additionally, they require the necessary permissions to create projects on the **parent**, which will either be the organization node or a folder.

## Repository Structure

The repository has the following structure:
* [/docs](./docs): General documentation about the repository and how to use it.
* [/modules](./modules): Customisable, reusable Terraform modules to create GCP infrastructure.
* [/scripts](./scripts): RAD-Lab Installer and additional scripts to support the modules.
* [/tools](./tools): Automation tools to generate the necessary documentation and license checks.

## Contributing

We welcome all contributions.  Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more information on how to publish your contributions. 
 