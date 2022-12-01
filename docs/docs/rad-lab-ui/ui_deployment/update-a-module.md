---
sidebar_position: 2
---

# Updating a Module

There are times you may want to update a module. Perhaps you...
- provided a bad config value on the initial deployment
- want to scale up or down certain resources
- have other reasons

<!-- TODO: Talk about how to update from the UI. Provide screenshots. -->

Select a deployment from within RAD Lab UI. Then select the Update button. Provide new values and submit a new build.

Behind the scenes were are calling `terraform apply` with the newly provided config values. Terraform will ensure these changes are reflected in your project.

