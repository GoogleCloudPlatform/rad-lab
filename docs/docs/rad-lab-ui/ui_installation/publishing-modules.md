---
sidebar_position: 5
title: 05 - Publishing Modules
---

# Publishing Modules

:::danger Important
No modules will be available for Users to deploy until an Admin publishes them.
:::

## Global Admin Variables

Some variables are common to all modules. Upon first log in, and Admin will set these variables, so that users will not need to add them. These include (but not limited to):

- Billing ID
- Folder ID
- Preferred Google Cloud Region and Zone

## Module Admin Variables

Lastly, some modules have specific requirements for variables that typical Users may not know, understand how to obtain, or even be authorized to access.

Once an Admin tries to publish a module, if the module requires any of these variables, the Admin will be prompted. These values will be saved in Firestore and inaccessible to Users.

When a User deploys a module, Global and Module Admin Variables will be combined with the variables the User provided and passed to Terraform for execution (User variables supersede all other variables of the same name, and Module Admin variable supersede Global Admin variables of the same name).
