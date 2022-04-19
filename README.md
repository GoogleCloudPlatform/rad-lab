# RAD Lab alpha fold module

RAD Lab enables users to deploy infrastructure on Google Cloud Platform (GCP) to support specific use cases. Infrastructure is created and managed through [Terraform](https://www.terraform.io/) in conjunction with support scripts written in Python. 
Bio-pharma organizations can now leverage the groundbreaking protein folding system, AlphaFold, with Vertex AI
Alphafold module deployment with radlab craetes a gcp project for researchers, enables Vertex AI APIs and deploys the alphafold container as a notebook in Vertex AI platform workbench.
We provide a customized Docker image in Artifact Registry, with preinstalled packages for launching a notebook instance in Vertex AI Workbench and prerequisites for running AlphaFold.


## GCP Products/Services

Vertex AI Workbench Notebooks with alphafold container to run alphafold demo

## Reference Architecture Diagram

Below Architechture Diagram is the base representation of what will be created as a part of [RAD Lab Launcher](../../radlab-launcher/radlab.py).

![](../../docs/images/V1_Alphafold.png)
Vertex AI lets you develop the entire data science/machine learning workflow in a single development environment, helping you deploy models faster, with fewer lines of code and fewer distractions.

For running AlphaFold, we choose Vertex AI Workbench user-managed notebooks, which uses Jupyter notebooks and offers both various preinstalled suites of deep learning packages and full control over the environment. We also use Google Cloud Storage and Google Cloud Artifact Registry, as shown in the architecture diagram above.We provide a customized Docker image in Artifact Registry, with preinstalled packages for launching a notebook instance in Vertex AI Workbench and prerequisites for running AlphaFold.


We provide sample alphafold.ipynb upyter Notebooks as part of radlab deployment. This notebook is maintained by Vertex AI samples.

Click on this blog to learn more about using this notebook https://cloud.google.com/blog/products/ai-machine-learning/running-alphafold-on-vertexai
    
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
 
