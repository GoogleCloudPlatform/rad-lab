# RAD Lab alpha fold module

RAD Lab enables users to deploy infrastructure on Google Cloud Platform (GCP) to support specific use cases. Infrastructure is created and managed through [Terraform](https://www.terraform.io/) in conjunction with support scripts written in Python. 

Alphafold module deployment with radlab craetes a gcp project for researchers, enables Vertex AI APIs and deploys the alphafold container as a notebook in Vertex AI platform workbench.


## GCP Products/Services

Vertex AI Workbench Notebooks with alphafold container to run alphafold demo

## Reference Architecture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Launcher](../../radlab-launcher/radlab.py).

![](../../docs/images/V1_DataScience.png)

We provide sample Jupyter Notebooks as part of data science module deployment. If you would like to include your own Jupyter Notebooks add them into [scripts/build/notebooks](./scripts/build/notebooks) folder and then run the deployment. You will be able to access your Jupyter notebooks from the Vertex AI Workbench Notebook created as part of the deployment.

    
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
* [/tools](./tools): Automation tools to generate the necessary documentation and license checks.

## Contributing

We welcome all contributions!  Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more information on how to publish your contributions. 
 
