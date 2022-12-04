---
sidebar_position: 2
title: 02 - Google Cloud
# TODO: See if there's a way to provide icons to steps
---

# Setting up Google Cloud

There are some preliminary steps that a Google Cloud Admin needs to complete manually before that can be run.

## Organization ID

You can follow these [steps](https://cloud.google.com/resource-manager/docs/creating-managing-organization#retrieving_your_organization_id) to get your Organization Resource ID. 

:::note
Organization ID is not required if you are deploying the module in a folder and setting `folder_id` variable in specific module deployment.
:::

:::tip
To spin up a RAD Lab module in a GCP project without any **Organization**, make sure to disable _orgpolicy.tf_ under `modules/[MODULE-NAME]/` by manually setting the default value of Orgpolicy variables  to **false** 

Example: set default value of `set_shielded_vm_policy` & `set_vpc_peering_policy` variables in [app_mod_elastic module](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules/app_mod_elastic)'s _variables.tf_ file to **false**)
:::

## Folder ID

RAD Lab will deploy its resources into newly created projects. We recommend that these projects should be placed within a Google Cloud Folder (see [Google Cloud resource hierarchy](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy)) 

Structuring projects this way allows easy implementation of access and security controls. This Folder will have a unique ID that you will provide to RAD Lab module to instruct it where to place resources.

## Billing ID

In order to provision Google Cloud resources, an active billing account is required. You will be asked to provide or select a Billing ID on the deployment via RAD Lab Launcher.

## Organization Policies

Some RAD Lab modules require permission to bypass several Google Cloud Organization Policies (if these are enabled at a higher level in the resource hierarchy). Each module will specify its requirements in this regard. We recommend editing the Organization Policies at the RAD Lab Folder level (**not** at higher folders or the organization level).  Do bear in mind that if it's necessary to manipulate organization policies, the identity running the Terraform code requires the IAM role Organization Policy Administrator ([`roles/orgpolicy.policyAdmin`](https://cloud.google.com/resource-manager/docs/access-control-org#using_predefined_roles)).
