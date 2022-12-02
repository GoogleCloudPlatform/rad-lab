---
sidebar_position: 1
title: 01 - Source Control
---

# Source Control

## Cloning official RAD Lab repository

1. [Download](https://github.com/GoogleCloudPlatform/rad-lab/archive/refs/heads/main.zip) the content to your local machine. Alternatively, you can check it out directly into Google Cloud Shell by clicking the button below. 

    :::tip 
    You will need to follow [these steps](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to set up a GitHub Personal Access Token with **repo** scope.
    :::

    [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/rad-lab&cloudshell_git_branch=main)

    :::note
    If you are using Windows OS make sure to deploy from `Command Prompt and Run as Administrator`.
    :::

2. Decompress the download:
   ```bash
   unzip rad-lab-main.zip
   ```

3. You will need [CURL](https://curl.se/) & [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). These come pre-installed in most linux terminals.

## Installing `Terraform` / `Python` / `gcloud` libraries

1. Navigate to the  `radlab-launcher` folder:
    ```bash
    cd ./rad-lab-main/radlab-launcher
    ```

2. Run a script to install the prerequisites:
    ```bash
    python3 installer_prereq.py
    ```
    **NOTE:** Currently the deployment is supported for `Python 3.7.3` and above.

    This will install:

    * _[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)_ binary by downloading a pre-compiled binary or compiling it from source.
    * A _[Python module](https://pypi.org/project/python-terraform/)_ which provides a wrapper of Terraform command line tool.
    * [Google API Python client library](https://cloud.google.com/apis/docs/client-libraries-explained#google_api_client_libraries) for Google's discovery based APIs.

3. Verify the Terraform installation by running:
    ```bash
    terraform -help
    ```

    This should produce instructions on running `terraform`. If you get a `command not found` message, there was an error in the installation.    
