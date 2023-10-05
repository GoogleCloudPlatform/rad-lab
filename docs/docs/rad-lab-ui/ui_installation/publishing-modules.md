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
- Organization ID (without `organizations/`-prefix)
- Folder ID (without `folders/`-prefix)
- Email Notification(enable/disable email notifications)

#### Email Notifications
You can optionally enable RAD Lab notification for deployment events. This includes deployment creations, updates, and deletions.

If enabled, the following users/groups (defined in the module's Terraform variables) will receive email notifications:
- The individual taking the action
- `trusted_users`
- `trusted_groups`
- `owner_users`
- `owner_groups`

Currently only sending via gmail is supported. It is recommended to [create a new gmail address](https://support.google.com/mail/answer/56256?hl=en) for this purpose only and generate an `App Password` to authenticate it by following [these directions](https://support.google.com/mail/answer/185833?hl=en).

 You will then provide this email and its password to RAD Lab UI via the `Global Variables` setup.

The email address will be store in Firestore, and email password will be securely stored in Google's [Secret Manager](https://cloud.google.com/secret-manager)

## Module Admin Variables

Lastly, some modules have specific requirements for variables that typical Users may not know, understand how to obtain, or even be authorized to access.

Once an Admin tries to publish a module, if the module requires any of these variables, the Admin will be prompted. These values will be saved in Firestore and inaccessible to Users.

When a User deploys a module, Global and Module Admin Variables will be combined with the variables the User provided and passed to Terraform for execution (User variables supersede all other variables of the same name, and Module Admin variable supersede Global Admin variables of the same name).

