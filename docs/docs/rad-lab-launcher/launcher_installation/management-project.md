---
sidebar_position: 3
title: 03 - RAD Lab Management Project
# TODO: See if there's a way to provide icons to steps
---

# Setup RAD Lab Management GCP Project

The RAD Lab Admin project will used as the the host project to deploy RAD Lab modules for your users. It will host the gcloud project config and the storage (via GCS) for Terraform state and the APIs.

:::warning Important
Ensure [01 - Source Control](../source-control) and [02 - Google Cloud](../setup-gcp) steps are complete before
proceeding
:::

## GCS Bucket for Terraform State

Create a [Cloud Storage Bucket](https://cloud.google.com/storage/docs/creating-buckets) within **RAD Lab Management Project** with read/write access to save the Terraform state for the entity (user or service account) spinning up the modules. This bucket is used to save state for all active deployments. 

:::tip Terrafrom State
We recommend to use a GCS bucket to store Terraform state instead of storing it locally, so that multiple Cloud admins can work through deploying the modules.
:::

## IAM Permissions Prerequisites

In addition to the [module](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules) specific minimum [IAM](https://cloud.google.com/iam/docs/overview) permissions (listed in Each [module](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules)'s `README.md`), entities deploying RAD Lab modules via **RAD Lab Launcher** will also need to have below permissions:
- Parent: `roles/iam.organizationRoleViewer` [OPTIONAL: This permission is not required if *no parent (organization/folder)* exists]
- RAD Lab Management Project: `roles/storage.admin`
- RAD Lab Management Project: `roles/serviceusage.serviceUsageConsumer`

You can use the Google Cloud Console to [view](https://cloud.google.com/iam/docs/manage-access-other-resources) or [change](https://cloud.google.com/iam/docs/manage-access-other-resources#single-role) IAM permissions.
