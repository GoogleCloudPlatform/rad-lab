
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [Unreleased]() (yyyy-mm-dd)
 
Here we write upgrading notes for RAD Lab repo. It's a team effort to make them as straightforward as possible.
 
### Added
 
### Changed
 
### Fixed

## [12.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v12.0.0) (2023-02-17)
 
### Added
- _RAD Lab Module:_ Releasing RAD Lab Secure Datawarehouse Module [(#136)](https://github.com/GoogleCloudPlatform/rad-lab/pull/136)

## [11.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v11.0.0) (2023-02-14)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v10.0.0...v11.0.0) 

### Added
- _RAD Lab Module:_ Releasing RAD Lab Genomics Nextflow Module [(#93)](https://github.com/GoogleCloudPlatform/rad-lab/pull/93) [(#94)](https://github.com/GoogleCloudPlatform/rad-lab/pull/94)

### Changed
- _RAD Lab Module:_ Standardizing Module specific READMEs [(#120)](https://github.com/GoogleCloudPlatform/rad-lab/pull/120)
- _Repo:_ Adding documentation on how to contribute to RAD Lab repo [(#106)](https://github.com/GoogleCloudPlatform/rad-lab/pull/106)
- _RAD Lab Documentation:_ Updating Documentation and adding Videos [[#92]](https://github.com/GoogleCloudPlatform/rad-lab/pull/92) [[#98]](https://github.com/GoogleCloudPlatform/rad-lab/pull/98) [[#128]](https://github.com/GoogleCloudPlatform/rad-lab/pull/128) 

## [10.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v10.0.0) (2022-11-14)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v9.1.1...v10.0.0) 

### Added
- _RAD Lab UI:_ Releasing RAD Lab UI [(#85)](https://github.com/GoogleCloudPlatform/rad-lab/pull/85)
- _RAD Lab Module:_ Releasing RAD Lab NEON Module [(#87)](https://github.com/GoogleCloudPlatform/rad-lab/pull/87)
- _Repo:_ Releasing RAD Lab Documentation [(#85)](https://github.com/GoogleCloudPlatform/rad-lab/pull/85)
 
### Fixed
- _RAD Lab Module:_ Fixed deployment issue for Silicon Design module. [(#86)](https://github.com/GoogleCloudPlatform/rad-lab/pull/86)
- _RAD Lab Module:_ Updated nodepool image in AppModElastic module. [(#83)](https://github.com/GoogleCloudPlatform/rad-lab/pull/83)
- _RAD Lab Module:_ Removed hardcoded references for zones in WebHosting module. [(#82)](https://github.com/GoogleCloudPlatform/rad-lab/pull/82)

## [9.1.1](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v9.1.1) (2022-10-21)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v9.0.0...v9.1.1) 
 
### Added
- _RAD Lab Module:_ Adding Project Owners to the RAD Lab module deployment. [(#75)](https://github.com/GoogleCloudPlatform/rad-lab/pull/75)

### Fixed
- _RAD Lab Module:_ Adding Storage Admin and Service User Consumer to Vertex AI Workbench Service Account in Data Science module. [(#80)](https://github.com/GoogleCloudPlatform/rad-lab/issues/80)

## [9.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v9.0.0) (2022-10-20)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v8.0.0...v9.0.0) 

### Added
- _RAD Lab Module:_ RAD Lab Web Hosting (3-tier architecture) Module [(#79)](https://github.com/GoogleCloudPlatform/rad-lab/pull/79)
- _RAD Lab Module:_ Added PubSub Topic & Subscription for Billing Budgets. [(#77)](https://github.com/GoogleCloudPlatform/rad-lab/pull/77)

### Changed
- _RAD Lab Module:_ Using deeplearning images in Silicon Design module. [(#50)](https://github.com/GoogleCloudPlatform/rad-lab/pull/50)
- _RAD Lab Module:_ Added permission to trusted users/groups for Genomics Cromwell Module. [(#81)](https://github.com/GoogleCloudPlatform/rad-lab/pull/81)

### Fixed
- _RAD Lab Module:_ Fixed the deployment issue for App Mod Elastic RAD Lab module. [(#74)](https://github.com/GoogleCloudPlatform/rad-lab/pull/74)

## [8.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v8.0.0) (2022-09-02)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v7.0.0...v8.0.0) 

### Added
- _RAD Lab Module:_ Added capability to deploy modules via Service Account Identity. [(#73)](https://github.com/GoogleCloudPlatform/rad-lab/pull/73)
- _RAD Lab Module:_ Added capability to enable Billing Budgets to all the modules. [(#73)](https://github.com/GoogleCloudPlatform/rad-lab/pull/73)
- _RAD Lab Module:_ Added Monitoring channels for Billing Budgets. [(#73)](https://github.com/GoogleCloudPlatform/rad-lab/pull/73)

### Changed
- _RAD Lab Launcher:_ Updated RAD Lab Launcher to support changing folder_id. [(ba072e0)](https://github.com/GoogleCloudPlatform/rad-lab/pull/73/commits/ba072e0d23f32310f57b696ec3e36068cf68e134)

### Fixed
- Fixed Hyperlinks. [(a7a2232)](https://github.com/GoogleCloudPlatform/rad-lab/pull/73/commits/a7a2232e0b4947569cca843aa07b486b649f6756)

## [7.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v7.0.0) (2022-05-24)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v6.1.1...v7.0.0) 
### Added
- _RAD Lab Module:_ RAD-Lab Billing Budget Module [(#58)](https://github.com/GoogleCloudPlatform/rad-lab/pull/58) 
- _Repo:_ Added a tool to create Terraform based [GCP Service Catalog solutions](https://cloud.google.com/service-catalog/docs/terraform-configuration) for RAD Lab modules. [(#56)](https://github.com/GoogleCloudPlatform/rad-lab/pull/56)
 
### Fixed
- _RAD Lab Module:_ Fixed Cloud NAT issue in [modules/genomics_cromwell/](https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules) [(#57)](https://github.com/GoogleCloudPlatform/rad-lab/issues/57) [(#61)](https://github.com/GoogleCloudPlatform/rad-lab/pull/61)
- _RAD Lab Launcher:_ Fixed the execution of gcloud commands within provisioner "local-exec" [(#62)](https://github.com/GoogleCloudPlatform/rad-lab/pull/62) [(#63)](https://github.com/GoogleCloudPlatform/rad-lab/pull/63)

## [6.1.1](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v6.1.1) (2022-04-26)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v6.0.0...v6.1.1)

### Added
 - _RAD Lab Launcher:_ Listing Existing Deployments when Updating/Deleting any deployment.[(#55)](https://github.com/GoogleCloudPlatform/rad-lab/pull/55)
### Fixed
- _RAD Lab Launcher:_ Fix for empty line in the file of "--varfile" used to cause error of "index out of range" and fail the execution of "python3 radlab.py --module.... --varfile ./xxxxx". [(#55)](https://github.com/GoogleCloudPlatform/rad-lab/pull/55)

## [6.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v6.0.0) (2022-04-19)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v5.1.1...v6.0.0)
### Added
 
- _RAD Lab Module:_ RAD-Lab alpha fold Module [(#54)](https://github.com/GoogleCloudPlatform/rad-lab/pull/54)

## [5.1.1](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v5.0.0) (2022-03-18)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v5.0.0...v5.1.1)

### Added
- _RAD Lab Module:_ Option to create container image Vertex AI notebooks in Data Science Module. [(#48)](https://github.com/GoogleCloudPlatform/rad-lab/pull/48)
- _RAD Lab Module:_ Capability for users to upload their own Jupyter notebooks to Vertex AI notebooks on Data Science Module deployment. [(#48)](https://github.com/GoogleCloudPlatform/rad-lab/pull/48)
- _RAD Lab Launcher:_ Enhancements to accept Command Line arguments. [(#41)](https://github.com/GoogleCloudPlatform/rad-lab/issues/41)[(#44)](https://github.com/GoogleCloudPlatform/rad-lab/pull/44)

### Changed
- _RAD Lab Launcher:_ Added a CLI argument / flag to disable RADLab Permission pre-checks. [(#46)](https://github.com/GoogleCloudPlatform/rad-lab/pull/46)

### Fixed
- _RAD Lab Launcher:_ Fixing links in the Error Messages. [(1e64c2d)](https://github.com/GoogleCloudPlatform/rad-lab/commit/1e64c2d2074c5688a589651ebaf2e1845370897a)
- _RAD Lab Launcher:_ Fixing a bug to also check for Owner role (i.e. roles/owner) which already contains all required permission for pre-checks for RAD Lab management project. [(#46)](https://github.com/GoogleCloudPlatform/rad-lab/pull/46)

## [5.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v5.0.0) (2022-02-23)

 [Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v4.2.1...v5.0.0)

### Added
   
- _RAD Lab Module:_ RAD-Lab Silicon Design Module [(#39)](https://github.com/GoogleCloudPlatform/rad-lab/pull/39)
 

## [4.2.1](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v4.2.1) (2022-02-17)
 
 [Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v4.1.0...v4.2.1)

### Changed
- _RAD Lab Launcher:_ Skipping installation of Terraform binaries on Cloud Shell as TF is automatically authenticated and is integrated with Cloud Shell [(294c096)](https://github.com/GoogleCloudPlatform/rad-lab/commit/294c0961ac24f666f55f6726a813cf8d47d80924)

### Fixed
- _RAD Lab Module:_ Resolved conflicting iam binding of notebooks.admin for `data_science` module. [(#43)](https://github.com/GoogleCloudPlatform/rad-lab/issues/43)

## [4.1.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v4.1.0) (2022-02-15)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v4.0.0...v4.1.0)

### Added
- _RAD Lab Launcher:_ Pre-Check IAM Permissions before deploying RAD Lab Modules. [(a28dbd2)](https://github.com/GoogleCloudPlatform/rad-lab/commit/a28dbd20145842db52a47a753a2d4a46d301a721) [(#10)](https://github.com/GoogleCloudPlatform/rad-lab/issues/10)[(#42)](https://github.com/GoogleCloudPlatform/rad-lab/issues/42)

### Changed
- _RAD Lab Launcher:_ Launcher to prompt for either proceeding with the existing GOOGLE_APPLICATION_CREDENTIALS or go through the login again. [(44cfae1)](https://github.com/GoogleCloudPlatform/rad-lab/commit/44cfae1eff7f5831b7e3712906edebf1eec7be89)
- _RAD Lab Module:_ Standardized Project ID prefix for all RAD Lab Module [(baba1f1)](https://github.com/GoogleCloudPlatform/rad-lab/commit/baba1f1484add9c0f88dd6b3efb0bc4104df23ec)[(992f8d5)](https://github.com/GoogleCloudPlatform/rad-lab/commit/992f8d5ae63e4c2295b651084982123c0ae01cfc)[(7dfe944)](https://github.com/GoogleCloudPlatform/rad-lab/commit/7dfe944efe074d91ed3c022b97c031aec49ddd91)[(827df14)](https://github.com/GoogleCloudPlatform/rad-lab/commit/827df141738ca264f1e785739a1973c7c2de53fc)

## [4.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v4.0.0) (2022-01-14)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v3.0.0...v4.0.0)

### Added
- _RAD Lab Module:_ RAD Lab Genomics-Cromwell Module [(039d522)](https://github.com/GoogleCloudPlatform/rad-lab/commit/039d52256d82d166ba03c4787e28ea6ebd7b0bae)
- _RAD Lab Launcher:_ Spinning up radlab modules via RAD Lab Launcher without an Organization [(f48cd8c)](https://github.com/GoogleCloudPlatform/rad-lab/commit/f48cd8c8a187ba5ed2e9d7a96e175f3327d406c3) [(#29)](https://github.com/GoogleCloudPlatform/rad-lab/issues/29)

### Changed
- _Repo:_ Setting up permissions in the GitHub Action workflows [(9351b47)](https://github.com/GoogleCloudPlatform/rad-lab/commit/9351b475ce29fe0809009c3030a8917287805cba)
- _RAD Lab Launcher:_ Launcher to prompt for Project ID for RAD Lab management [(a2c42af)](https://github.com/GoogleCloudPlatform/rad-lab/commit/a2c42af9f272adad6aa9fa5d2aa5d4a3949d7cee) [(#9)](https://github.com/GoogleCloudPlatform/rad-lab/issues/9)
- _RAD Lab Module:_ Updated AI Notebook Image to include sample notebook for Data Science RAD Lab Module [(05985fa)](https://github.com/GoogleCloudPlatform/rad-lab/commit/05985faa0d18b5ebb132e7cd138422e3e00c6a8f)

### Fixed
- _Repo:_ Fixed GitHub Action Workflow - Build Module README [(3d7e7b8)](https://github.com/GoogleCloudPlatform/rad-lab/commit/3d7e7b81060e05f41a6b12ad79f95eae93ab10a8) [(#38)](https://github.com/GoogleCloudPlatform/rad-lab/issues/38)

## [3.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v3.0.0) (2021-12-06)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v2.1.0...v3.0.0)

### Added
- _RAD Lab Module:_ RAD Lab Genomics-databiosphere dsub Module [(febc5f2)](https://github.com/GoogleCloudPlatform/rad-lab/commit/febc5f28d1b9c2fb91b4992ce2884f575d16d8a2)

## [2.1.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v2.1.0) (2021-11-23)
 
[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v2.0.0...v2.1.0)

### Added
- _RAD Lab Launcher:_ Added optional Input file parameter to set variables & create terraform.tfvars file [(dfdb270)](https://github.com/GoogleCloudPlatform/rad-lab/commit/dfdb270f3cdb25fc57715e14ba7cdc83edbe9e95)

### Changed
- _RAD Lab Launcher:_ Changed how module selection works [(#7)](https://github.com/GoogleCloudPlatform/rad-lab/issues/7)


## [2.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v2.0.0) (2021-11-15)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v1.1.0...v2.0.0)
 
### Added

- _RAD Lab Module:_ RAD Lab Application Mordernization Module (w/ Elasticsearch) [(f228685)](https://github.com/GoogleCloudPlatform/rad-lab/commit/f2286855bceb48bcb42cdacc954b8b0f8afe0d1e)
- _RAD Lab Module:_ Functionality to deploy RAD Lab modules in existing GCP projects [(69cab34)](https://github.com/GoogleCloudPlatform/rad-lab/commit/69cab3449b2a7c4d564b94d8c19e82c2fcc80b4e)
- _RAD Lab Module:_ Functionality to deploy in existing network/subnet [(7bd10fb)](https://github.com/GoogleCloudPlatform/rad-lab/commit/7bd10fbb09646e26e89b82fb5fe5b6ca7cdaa0f5)
- _RAD Lab Launcher:_ Functionality to list existing RAD Lab deployments for specific modules [(620dd64)](https://github.com/GoogleCloudPlatform/rad-lab/commits/620dd64ec7fe6eb8621849b792321b59e78ab0f1)
- _RAD Lab Launcher:_ Functionality to enter Org ID & Billing A/C manually [(2db2dae)](https://github.com/GoogleCloudPlatform/rad-lab/commit/2db2daeac56c24aa910a879f7ecac528d1a97482)
- _GitHub Action:_ Check - Apache 2.0 License Boilerplate [(5ee285d)](https://github.com/GoogleCloudPlatform/rad-lab/commit/5ee285dbee67403a1477ccfcdc3b885d7d95d8b7)
- _GitHub Action:_ Build - Notifications to RAD Lab team [(26f33af)](https://github.com/GoogleCloudPlatform/rad-lab/commit/26f33afdeba91488c72c40988b03a60ae18c156c)

### Changed
- _Repo:_ Restructuring & Documentation Update [(f775701)](https://github.com/GoogleCloudPlatform/rad-lab/commits/f775701d225bd193042975a5aad4e0669ec9596f)
- _RAD Lab Module:_ Added timer to wait for Org Policy to get rolled out [(99f1e7f)](https://github.com/GoogleCloudPlatform/rad-lab/commit/99f1e7f659a98ba22cf45a64052a5bcaf5eae948)
- _RAD Lab Launcher:_ Re-branding RAD Lab Installer to RAD Lab Launcher [(9a67462)](https://github.com/GoogleCloudPlatform/rad-lab/commit/9a67462c45bc162f2a5f226eefbe123a092a6c8c)
- _GitHub Action:_ Check - Terraform Plan [(f491556)](https://github.com/GoogleCloudPlatform/rad-lab/commit/f491556daf38e2b4cfbcf509e2ed0611b40a8d51)

### Fixed
- _Repo:_ Broken link to gcp-ai-nootbook-tools [(#12)](https://github.com/GoogleCloudPlatform/rad-lab/issues/12)


## [1.1.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v1.1.0) (2021-11-01)

[Full Changelog](https://github.com/GoogleCloudPlatform/rad-lab/compare/v1.0.0...v1.1.0)

### Added
- _Repo:_ Enabling Codeowners [(1b34ab2)](https://github.com/GoogleCloudPlatform/rad-lab/commit/1b34ab2ae7fcccd3db8736aff89cc35c3a0b9b54)
- _Repo:_ Tools for workflow automation [(74a99a4)](https://github.com/GoogleCloudPlatform/rad-lab/commit/74a99a4f20c63e37b94c1da4bf912be51231a94a)
- _Repo:_ Created Issue Templates [(ce531bc)](https://github.com/GoogleCloudPlatform/rad-lab/commit/ce531bc89bff2a2e8baa1247b9259e4e2b1b05d4)
- _GitHub Action:_ Build - Terraform Plan [(2270904)](https://github.com/GoogleCloudPlatform/rad-lab/commit/22709045f91654149c397b352653bc0ba4a0ac38)
- _GitHub Action:_ Auto-create Variables/Outputs in Module README [(9a54a12)](https://github.com/GoogleCloudPlatform/rad-lab/commit/9a54a12e07429cbf93eaa534bd35b8ea7607b6a3)
- _Repo:_ Enabling Changelog [(3536b18)](https://github.com/GoogleCloudPlatform/rad-lab/commit/3536b18806ecd4cdf9e393819454e8154c61c37f)

### Changed
- _Repo:_ Re-structured Documentation [(51831c6)](https://github.com/GoogleCloudPlatform/rad-lab/commit/51831c63ea57b31ed4a7c78872c797cc92bc9692)
- _RAD Lab Launcher:_ Making RAD Lab Installer compatible with restructured repo directory [(3b03ca2)](https://github.com/GoogleCloudPlatform/rad-lab/commit/3b03ca26a756993ce718e001ec4c7d351a5e0955)

 
## [1.0.0](https://github.com/GoogleCloudPlatform/rad-lab/releases/tag/v1.0.0) (2021-10-07)
 
### Added
   
- _RAD Lab Module:_ RAD-Lab Data Science Module [(c3a185f)](https://github.com/GoogleCloudPlatform/rad-lab/commit/c3a185fb33223095822546952071150f2a5bc089)
 
