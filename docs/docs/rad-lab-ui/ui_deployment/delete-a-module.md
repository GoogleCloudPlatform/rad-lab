---
sidebar_position: 3
---

# Delete a Module

You may want to delete a module. Perhaps you...
- deployed incorrectly
- have finished the work intended for the module
- are looking to tear down Google Cloud resources to save costs

<!-- TODO: Talk about how to delete from the UI. Provide screenshots. -->
Select a deployment from within RAD Lab UI. Then select the Delete button. Confirm that you would like to delete.

Behind the scenes were are calling `terraform destroy` to decomission the Google Cloud resources in the project.

<!-- TODO: Double check if the project will be deleted or if manual intervention is required here -->

