---
sidebar_position: 2
title: 02 - Google Cloud
# TODO: See if there's a way to provide icons to steps
---

# Setting up Google Cloud

We provide a Terraform script to bootstrap much of RAD Lab UI; however, there are some preliminary steps that a Google Cloud Admin needs to complete manually before that can be run.

## RAD Lab Folder

RAD Lab UI will deploy its resources into newly created projects. These projects should be placed within a Google Cloud Folder (see [Google Cloud resource hierarchy](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy)) 

Structuring projects this way allows easy implementation of access and security controls. This Folder will have a unique ID that you will provide to RAD Lab UI to instruct it where to place resources.

## Billing ID

In order to provision Google Cloud resources, an active billing account is required. You will be asked to provide a Billing ID on initial set up of RAD Lab UI.

## Organization Policies

Some RAD Lab modules require permission to bypass several Google Cloud Organization Policies (if these are enabled at a higher level in the resource hierarchy). Each module will specify its requirements in this regard. We recommend editing the Organization Policies at the RAD Lab Folder level (**not** at higher folders or the organization level).  Do bear in mind that if it's necessary to manipulate organization policies, the identity running the Terraform code requires the IAM role Organization Policy Administrator ([`roles/orgpolicy.policyAdmin`](https://cloud.google.com/resource-manager/docs/access-control-org#using_predefined_roles)).

## Authorizing Users

Only Users and Admins that have been placed in the appropriate Google Cloud Identity groups can access RAD Lab UI. We suggest creating groups called `rad-lab-admins` and `rad-lab-users` in your identity provider (e.g. Active Directory, Google Workspace, etc) and start by adding yourself (the Admin) to the `rad-lab-admins` group.

You will then provide these groups to the RAD Lab UI setup. When users sign in to the RAD Lab UI, they will be checked for membership in either of these two groups and assigned a role appropriately (or blocked if in neither group).

For the UI to be able to do this, the service account attached to the web application must be granted certain permissions at Google Admin level.  The user granting these permissions should have Super Admin access. Follow steps [here](infrastructure.md#admin-api).
