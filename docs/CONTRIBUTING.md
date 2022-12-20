# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution;
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## RAD Lab Repository

We love and encourage your contributions to the RAD Lab repo. Follow the steps below to contribute on `features` and `bug fixes` for RAD Lab:

1. **Fork** the public [RAD Lab repo](https://github.com/GoogleCloudPlatform/rad-lab)
2. Create a `feature branch` from the `main` branch of your **forked** repo.

    NOTE: Before you create the `feature branch` make sure that the `main` branch of your **forked** repo is in sync with the `main` branch of public RAD Lab repo.

3. Once the development is completed, raise a PR to merge the `feature branch` (of your **forked** repo) into [`staging`](https://github.com/GoogleCloudPlatform/rad-lab/tree/staging) branch of the **RAD Lab** public repo.

    NOTE: Make sure that there are **no conflicts** and the _testing is completed on the raised PR itself_.

4. [Code Owners](../CODEOWNERS) will [review the PR](CONTRIBUTING.md#code-reviews) and _squash & merge_ it into [`staging`](https://github.com/GoogleCloudPlatform/rad-lab/tree/staging) branch of the **RAD Lab** public repo.
5. GitHub Actions tests and UI testing will be done on the internal RAD Lab staging environment, which points to the [`staging`](https://github.com/GoogleCloudPlatform/rad-lab/tree/staging) branch of the **RAD Lab** public repo.
6. After all the testing is completed, [Code Owners](../CODEOWNERS) will _rebase and merge_ the [`staging`](https://github.com/GoogleCloudPlatform/rad-lab/tree/staging) branch into [`main`](https://github.com/GoogleCloudPlatform/rad-lab/tree/main) branch of the **RAD Lab** public repo.

## Repository Structure

The project has the following file structure:
- [/docs](../docs): Documentation about the repository.
- [/modules](../modules): Customisable modules to create Google Cloud Platform infrastructure & supporting scripts.
- [/radlab-launcher](../radlab-launcher): RAD-Lab Launcher and associated scripts to support the modules.
- [/radlab-ui](../radlab-ui/): Source code to deploy RAD Lab UI.

Every individual module is contained in it subdirectory and should follow these guidelines:

- Create at least a `versions.tf`, `main.tf`, `variables.tf` and `outputs.tf`.  It's ok to create additional files, to split resources between files and give them more meaningful names. 

    NOTE: Make sure all the variables are in alphabetical order in `variables.tf`

- If any additional scripts (apart from **terraform** configs) are required to support the module either to *build* or *use* the module, move them to individual module's subdirectory, example: `/modules/[MODULE-NAME]/scripts/build` & `/modules/[MODULE-NAME]/scripts/usage` respectively. 

- Add the GCP architecture diagram under `modules/[MODULE_NAME]/images` with filename as `architecture.png` for respective module.

- A **README.md** containing more information about the modules, required IAM permissions and any specific instructions to create the infrastructure, etc. Make sure to add at least the below mentioned Headings & Sub Headings:

    - HEADING:
        - `# RAD LAB [MODULE-NAME] Module` : Title of the Module Specific README.

    - SUB-HEADINGS:
        - `## Module Overview` : Description about the module. 
        - `## GCP Products/Services`: List the GCP products and the sevices used in the respective module development.
        - `## Reference Architecture Diagram` : Add the GCP architecture diagram under this section. Images for module specific architechture diagrams should be stored under `modules/[MODULE_NAME]/images` with filename as `architecture.png` for respective module.

    NOTE: Add the below two tags in the RAD-Lab module specific README.md for populating structured Variables and Outputs automatically via [tfdoc.py](../tools/tfdoc.py).

    ```
    <!-- BEGIN TFDOC -->
    <!-- END TFDOC -->
    ```

For every module, a base configuration is determined, which can be deployed via the [radlab.py](../radlab-launcher/README.md) launcher.  The base configuration is reflected in the default values for all the variables, except for `organization_id`, `billing_account_id` and (optional) `folder_id`. 

## RAD Lab Launcher
It should be possible for people with less experience in Infrastructure As Code to use every module.  The repository contains a launcher for that purpose, which can be found in the [/radlab-launcher](../radlab-launcher) directory ([radlab.py](../radlab-launcher/radlab.py)).  The launcher needs to be updated whenever new modules are introduced to the repository.

## Cloud Foundation Toolkit
Where possible, use the open source [Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit) modules to create Google Cloud infrastructure.

## Code Reviews

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. 
NOTE: Create a **seperate pull request** for every module you create or update. Do not include changes of multiple modules in the same pull request.  

Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests.

## Community Guidelines

This project follows [Google's Open Source Community Guidelines](https://opensource.google/conduct/).