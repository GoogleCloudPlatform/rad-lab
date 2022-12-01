---
title: 06 - Cleanup Environment
sidebar_position: 6
---

The RAD Lab UI project can be deleted by executing the following steps in the `radlab-ui/automation/terraform/infrastructure` folder.

1. Delete the `backend.tf` file.
2. Run `terraform init -migrate-state`. This will copy the remote state to your local environment.
3. Run `terraform destroy -auto-approve`. This will delete the RAD Lab UI project and all the IAM permissions that were created as part of the installation.

<!-- TODO: Purge the environment. -->
