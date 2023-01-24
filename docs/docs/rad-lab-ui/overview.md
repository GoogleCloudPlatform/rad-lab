---
sidebar_position: 1
---
# Overview
The RAD Lab UI codebase contains the necessary Terraform and frontend code to deploy the RAD Lab UI web application in your Google Cloud organization. This guide services as a step-by-step instruction to deploy and configure everything in a secure way.

## Architecture

![](../../../radlab-ui/images/architecture.png)

To install the UI, a combination of Terraform and shell scripts is used to create the necessary Google Cloud components and configure the web application. Once this step is completed, users will be able to create RAD Lab modules via the user interface (once they've been given access). The components that are part of the purple (left) box are the services used to run the user interface. The components in the blue (right) box are RAD Lab modules that are created by the user and where the lifecycle is managed via the UI.

## Components

### Terraform
As part of the installation instructions, Terraform will be used to create the following components:
- Google Cloud project (including APIs), for the UI infrastructure
- A number of Cloud Functions, which are used by the RAD Lab UI to create RAD Lab modules
- Google App Engine application to host the UI
- Firebase application to manage routing, security, etc
- Google Cloud Storage buckets for the Terraform state files, for both the UI and the individual RAD Lab modules
- Necessary service accounts with IAM permissions, needed for their activities
- Cloud Build triggers to deploy the RAD Lab modules

### Shell scripts
the cloud admin will have to run a number of shell scripts to configure the firebase application, incl. firestore rules and configuration specific to the ui.

### Manual Tasks

The manual activities can be split in two separate sections:
- Google Admin
- Firebase

#### Google Admin
To grant access to users and to ensure that the application can validate group memberships, it's necessary to create groups and assign a custom role to service accounts when installing the RAD Lab UI.

#### Firebase 
Invoking Firebase APIs via Infrastructure as Code from a terminal requires the use of a Google Cloud service account.  This is not supported by the RAD Lab UI, so the following steps have to be completed manually before the installation can be completed:
- Create the Firebase application
- Enable authentication mechanisms

## Deploying a RAD Lab Module

![](../../../radlab-ui/images/flow.png)

The diagram depicts the flow to deploy a RAD Lab module, as a RAD Lab user, via the UI.  The steps to update and delete a module follow a similar pattern, so they are not repeated here. 

### Steps

When users create a RAD Lab module, the following steps are being executed by the underlying backend components:
1. Users select a module from the UI and click Create, supplying the necessary values for the Terraform variables.
1. The UI posts a message to a Pub/Sub topic, passing the values for the variables in `variables.tf` for that specific module and some [additional information](../../../radlab-ui/automation/terraform/infrastructure/function/create_deployment/index.js).
1. The Cloud Function creates two files, `backend.tf` and `terraform.tfvars.json`.  `backend.tf` contains information regarding Terraform remote state for that specific module creation and `terraform.tfvars.json` contains the values for `variables.tf` for that specific module.
1. Once the previous step is completed, the Cloud Function invokes the Cloud Build trigger to create the RAD Lab module and stores the unique build ID from Cloud Build in Firestore.
1. The RAD Lab UI retrieves the build ID for that specific RAD Lab module and polls the Cloud Build APIs to display the build status and logs.
