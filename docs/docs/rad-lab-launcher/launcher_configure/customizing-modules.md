---
sidebar_position: 1
---

# Customizing Modules

After you have [cloned the the official RAD Lab repository](../../launcher_installation/source-control), you can customize every module's defaults to match your organization's needs.

## Overriding default variables of a RAD Lab Module

To set any module specific variables, use `--varfile` argument while running [RAD Lab Launcher](../launcher_deployment/launcher.md) (**radlab.py**) and pass a file with variables content. Variables like **organization_id**, **folder_id**, **billing_account_id**, **random_id** (a.k.a. **deployment id**), which are requested as part of guided setup, can be set via `--varfile` argument by passing them in a file. 

Based on the [module](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules) which you are deploying, review the `variables.tf` file to determine the type of variable, and accordingly, set the variable values in the file to override the default variables.

_Usage :_
```bash
python3 radlab.py --varfile /<path_to_file>/<file_with_terraform.tfvars_contents>
```

**NOTE:** When the above argument is not passed then the modules are deployed with module's default variable values in the `variables.tf` file.
