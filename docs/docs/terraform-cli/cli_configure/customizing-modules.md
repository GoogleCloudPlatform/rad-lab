---
sidebar_position: 1
---

# Customizing Modules

After you have [cloned the the official RAD Lab repository](../../cli_installation/source-control), you can customize every module's defaults to match your organization's needs.

## Overriding default variables of a RAD Lab Module

* Step down in the directory that contains the module specific Terraform code

```bash
cd modules/[MODULE_NAME]
```
* Create a `terraform.tfvars` file. Below are the bare minimum require variables; feel free to override any other variables where you see fit.

```bash
cat <<EOT > terraform.tfvars
billing_account_id = "ABCD-ABCD-ABCD"
organization_id    = "12345678901"
folder_id          = "98765432101"
EOT
```
