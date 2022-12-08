---
sidebar_position: 1
---

# Deploy a Module

This is the primary flow and purpose for RAD Lab UI. A step-by-step graphical interface will prompt you for the variables needed to deploy the selected module to Google Cloud.

Admins and Users are both able to deploy modules.

The video below provides a quick overview on how to setup RAD Lab UI variables and deploy RAD Lab modules.

<iframe
    width="980"
    height="480"
    src="https://www.youtube.com/embed/8KNDAIb-Z2I"
    frameborder="0"
    allow="encrypted-media"
    allowfullscreen
>
</iframe>

## Prerequisites

Users can only deploy modules that Admins have explicitly published. If there are no options available, please talk to your Admin.

When an Admin is publishing a module, there may be a few admin-only variables for the Admin to provide. These will be merged in with the variables the User provides.

## The Process

1. A User (or Admin) selects a module they wish to deploy (e.g. Data Science)
1. They are prompted for all the required variables needed to deploy
    - Some variables may already be provided as defaults
1. The user submits 
1. A Cloud Build job will be started to deploy the resources
   1. A unique Deployment ID for the deployment will be generated
   1. A new Google Cloud project will be created using this Deployment ID
   1. A deployment folder in GCS will be created (within the Admin configured bucket)
   1. Terraform files will be written to the folder including a variables file consisting of the Admin and User provided variables
1. The User will be taken to a page representing their deployment
1. The user will see the deployment in the "Running" status
    - The status may change over time. The possible statuses and their explanations can be seen [here](https://cloud.google.com/build/docs/api/reference/rest/v1/projects.builds#status)
1. After some time (up to 1 hour), the deployment will complete, fail, or time out
    - Logs of the build will be streamed to monitor status or troubleshoot errors

<!-- TODO: Add screen shots -->

