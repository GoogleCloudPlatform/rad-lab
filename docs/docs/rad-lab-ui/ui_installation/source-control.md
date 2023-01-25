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

### Cloud Build and GitHub integration

Before continuing, make sure that the [Cloud Build integration](https://github.com/marketplace/google-cloud-build) is configured correctly.  Click on **Setup a plan**, subsequently followed by **Setup with Google Cloud Build**.

Make a note of your new GitHub repository URL, as you will need it when going through the next steps.
