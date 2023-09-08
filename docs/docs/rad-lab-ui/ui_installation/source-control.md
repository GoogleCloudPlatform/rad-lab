---
sidebar_position: 1
title: 01 - Source Control
---

# Source Control

Users either have the option to fork the official [RAD Lab repository](https://github.com/GoogleCloudPlatform/rad-lab) or to clone the existing repository and push the code to a repository they manage and control.  The problem is that forking a repo results in a public repository, which may violate existing security policies in your organization.  

:::tip Clone Repository
It's our recommendation to clone the repository and push it to your own, privately hosted Github repository.  
:::

For now, RAD Lab only supports GitHub, but this may change in the future.  When pushing the code to GitHub, ensure that it's configured to work together with the [Cloud Build integration](https://github.com/marketplace/google-cloud-build).  

:::tip GitHub Actions
It's a good idea to remove the `.github` folder (or create a backup) initially, as otherwise you may receive several failed build emails.
:::

## Cloud Build and GitHub integration

Before continuing, make sure that the [Cloud Build integration](https://github.com/marketplace/google-cloud-build) is configured correctly.  Click on **Setup a plan**, subsequently followed by **Setup with Google Cloud Build**.

Make a note of your new GitHub repository URL, as you will need it when going through the next steps.

## Merging upstream

As our recommendation is to clone the repository and upload it to a private repository in your control, you need a mechanism to merge updates from the official RAD Lab repository.  There are several to execute this flow and what works best in your organization will depend on a number of factors.  We however recommend creating a branch in your repository, download the latest version from [the official RAD Lab repository](https://github.com/GoogleCloudPlatform/rad-lab) and, after reviewing whether or not the changes are relevant for your organization, you can copy the updated codebase to this newly created branch.  

If only the `modules` have received an update, there is no need to update the UI either.  However, if files in `radlab-ui` were changed, you will have to go through the deployment steps again to update the infrastructure and deploy the updated UI.  

You can find more detailed steps in this [StackOverflow-post](https://stackoverflow.com/a/1684694).
