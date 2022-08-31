# Supporting Tools

This document explains the different types of supporting tools included in this repo which you can utilize for building & supporting RAD Lab modules.

:green_circle: _These tools are built on Python and supported for `Python 3.7.3` & above._

### OS Support:
- Mac
- Windows
- Linux

## 1. Terraform Module Doc Builder

### WHAT?

This tool builds the variables & outputs of a terraform module and add it to the README.md of the module.

### HOW?

#### STEP 1

Add below 2 tags in the Argolis Common Problems TF solution specific README.md for populating structured Variables and Outputs automatically via [tfdoc.py](tfdoc.py).

```
<!-- BEGIN TFDOC -->
<!-- END TFDOC -->
```

#### STEP 2
```python3 tfdoc.py <path/to/tf/module>```

Example:

```python3 tfdoc.py ./../modules/data_science```

## 2. License Boilderplate

### WHAT?

This tool returns the list of files (with complete file paths) which are missing Apache 2.0 Lisence.

:green_circle: _The checks are done on *Dockerfile* , *.py*, *.sh*, *.tf*,
*.yaml*, *.yml* file types._

### HOW?

```python3 check_boilerplate.py <path/to/folder>```

## 3. RADLab Service Catalog Solution Builder

### WHAT?

This tool converts respective RAD Lab module into the zipped file which can be used as the [Terraform config solution](https://cloud.google.com/service-catalog/docs/terraform-configuration#create_module) for Service Catalog.

:green_circle: _Follow Service Catalog quickstart [guide](https://cloud.google.com/service-catalog/docs/quickstart) to Setup a catalog & RadLab Solutions within the catalog._

### HOW?

```python3 service-catalog.py```

#### Example Run

```
% python3 service-catalog.py

List of available RAD Lab modules:
[1] # RAD Lab alpha fold module (alpha_fold)
[2] # RAD Lab Application Mordernization Module (w/ Elasticsearch) (app_mod_elastic)
[3] # RAD Lab Data Science Module (data_science)
[4] # RAD Lab Genomics-Cromwell Module (genomics_cromwell)
[5] # RAD Lab Genomics Module (genomics_dsub)
[6] # RAD Lab Silicon Design Module (silicon_design)
[7] Exit
Choose a number for the RAD Lab Module: 1

RAD Lab Module (selected) : alpha_fold
  adding: main.tf (deflated 69%)
  adding: orgpolicy.tf (deflated 64%)
  adding: outputs.tf (deflated 46%)
  adding: scripts/ (stored 0%)
  adding: scripts/.DS_Store (deflated 96%)
  adding: scripts/usage/ (stored 0%)
  adding: scripts/build/ (stored 0%)
  adding: scripts/build/startup_script.sh (deflated 53%)
  adding: variables.tf (deflated 70%)
  adding: versions.tf (deflated 40%)
Please find the zipped solution here: /<path_to_repo_tools>/rad-lab/tools/radlab-service-catalog/alpha_fold.zip
```

## 4. GitHub Actions Scripts

Below 4 scripts are used in the respective GitHub actions:

- [BUILD - Module README](../.github/workflows/build-module-readme.yml) :  Uses [build_readme.py](build_readme.py) & [tfdoc.py](tfdoc.py) for a specific Pull Request and make sure that details of the Variables and Outputs of a module is documented in respective module README.
- [CHECK - License Boilerplate](../.github/workflows/check-license.yml) :  Uses [check_documentation.py](check_documentation.py) & [check_boilerplate.py](check_boilerplate.py) for a specific Pull Request and make sure that Apache 2.0 License header are added to the files.
- [CHECK - Terraform Plan](../.github/workflows/check-tf-plan.yml) :  Uses [check-tf-plan.py](check-tf-plan.py) for a specific Pull Request and run the `terraform init` and `terraform plan` unit testing for any RADLab module addition/modification.
- [BUILD - RAD Lab Notifications](../.github/workflows/notifications.yml) : Uses [notications.py](notifications.py) to send out notifications to the Repo Admins/Maintainers for any new pull or issue request.