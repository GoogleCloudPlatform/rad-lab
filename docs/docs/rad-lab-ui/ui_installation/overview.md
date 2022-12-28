---
sidebar_position: 1
title: 01 - Overview
---
# Overview

The RAD Lab UI codebase contains the necessary Terraform and frontend code to deploy the web application in your Google Cloud organization.  This guide services as a step-by-step instruction to deploy and configure everything in a secure way.

## Architecture

![](../../../../radlab-ui/images/architecture.png)

To install the UI, a combination of Terraform and shell scripts is used to create the necessary Google Cloud components and configure the web application.  Once this step is completed, users will be able to create RAD Lab modules via the user interface, once they've been given access.  The components that are part of the purple box are the services used to run the user interface.  The components in the blue box are RAD Lab modules that are created by the user and where the lifecycle is managed via the UI.

## Components

### Terraform
As part of the installation instructions, Terraform will be used to create the following components:
- Google Cloud project, including APIs
- A number of Cloud Functions, which are used by the RAD Lab UI to create RAD Lab Mod
- Google App Engine application to host the UI
- Firebase application to manage routing, security, ...
- Google Cloud Storage buckets for the Terraform state files, for both the UI and the individual RAD Lab modules
- Necessary service accounts with IAM permissions, needed for their activities
- Cloud Build triggers to deploy the RAD Lab modules

### Shell scripts
The Cloud Admin will have to run a number of Shell scripts to configure the Firebase application, incl. Firestore rules and configuration specific to the UI.

### Manual

The manual activities can be split in two separate sections:
- Google Admin
- Firebase

### Google Admin
To grant access to users and to ensure that the application can validate group memberships, it's necessary to create groups and assign a custom role to service accounts when installing the RAD Lab UI.

### Firebase 
Invoking Firebase APIs via Infrastructure as Code from a terminal requires the use of a Google Cloud service account.  This is not supported by the RAD Lab UI, so the following steps have to be completed manually before the installation can be completed:
- Create the Firebase application
- Enable authentication mechanisms

## Flow

![](../../../../radlab-ui/images/flow.png)

### Steps

When users create a RAD Lab module, the following steps are being executed by the underlying backend components:
1. Users select a module from the UI and click Create, supplying the necessary values for the Terraform variables.
2. The UI posts a message to a Pub/Sub topic, passing the values for the variables in `variables.tf` for that specific module and some [additional information](../../../../radlab-ui/automation/terraform/infrastructure/function/create_deployment/index.js).
3. The Cloud Function creates 2 files, `backend.tf` and `terraform.tfvars.json`.  `backend.tf` contains information regarding Terraform remote state for that specific module creation and `terraform.tfvars.json` contains the values for `variables.tf` for that specific module.
4. Once the previous step is completed, the Cloud Function invokes the Cloud Build trigger to create the RAD Lab modules and stores the unique build ID from Cloud Build in Firestore.
5. The RAD Lab UI retrieves the build ID for that specific RAD Lab module and polls the Cloud Build APIs for the build status and logs for that particular RAD Lab module.