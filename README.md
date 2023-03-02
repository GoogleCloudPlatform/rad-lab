# RAD Lab

RAD Lab enables users to deploy infrastructure on Google Cloud Platform (GCP) to support specific use cases. Infrastructure is created and managed through [Terraform](https://www.terraform.io/) in conjunction with support scripts written in Python. The templates, code, and documentation for each use case are bundled into [modules](./modules).

Each module comes with an initial sample configuration that can be deployed via the [RAD Lab Launcher](./radlab-launcher). Teams with experience in Terraform can use the Terraform modules in the [/modules-directory](./modules) directly, to integrate the codebase with their existing CI/CD infrastructure.

For any issues, please create an issue in the Issue tracker of the repository, following the provided templates.

## Disclaimer

This is not an officially supported Google product

## Quick Start

To create a module in an existing GCP environment, please click on the “Open In Cloud Shell” button.  This will clone the entire repository to Cloud Shell and automatically select the `main`-branch.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)
    
### Prerequisites
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started) version 1.0 or higher.
* [gcloud](https://cloud.google.com/sdk/docs/install) SDK version 360.0.0 or higher. (ONLY for [RAD Lab Launcher](./radlab-launcher))
* [python](https://www.python.org/downloads/) version 3.7.3 or higher. (ONLY for [RAD Lab Launcher](./radlab-launcher))

Users can run `installer_prereq.py` included in the [radlab-launcher directory](./radlab-launcher) to validate these prerequisites and install any missing dependencies.

### RAD Lab Launcher
An installation script is included to enable users without prior cloud or Terraform experience to explore the advantages of GCP.  The deployment wizard will create the necessary infrastructure for each module.  More instructions on the launcher can be found [here](./radlab-launcher).

### Modules

The [modules](./modules) directory contains Terraform modules that can be integrated in existing CI/CD pipelines.  We recommend creating a fork from this repository and use that as part of your overall workflow to create infrastructure.  While we will make an effort to provide backwards compatibility, we cannot guarantee it with every release.

### Permissions

Each module will list the minimum IAM permissions users require to successfully create the infrastructure.

Additional [permissions](./radlab-launcher/README.md#iam-permissions-prerequisites) are required when deploying the RAD Lab modules via [RAD Lab Launcher](./radlab-launcher)

## Repository Structure

The repository has the following structure:
* [/docs](./docs): General documentation about the repository and how to use it.
* [/modules](./modules): Customisable, reusable Terraform modules to create GCP infrastructure & supporting scripts.
* [/radlab-launcher](./radlab-launcher): RAD Lab Launcher and associated scripts to support the modules.
* [/radlab-ui](./radlab-ui): RAD UI and associated scripts to build the WebApp.
* [/tools](./tools): Automation tools to generate the necessary documentation and license checks.

## Contributing

We welcome all contributions!  Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more information on how to publish your contributions. 
 
