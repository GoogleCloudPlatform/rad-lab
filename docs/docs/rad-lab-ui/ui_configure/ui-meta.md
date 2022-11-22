---
sidebar_position: 1
---

# RAD Lab UI Meta

To enable programmitic generation of the UI, we have introduced a custom syntax or Domain Specific Language (DSL) that RAD Lab UI parses. Within the Terraform variable files (`.tfvars`) some fields have a `{{UIMeta ... }}` tag within the variable's `description` field (we chose the `description` field because it is not interpreted by Terraform in any semantic way).

Below are the keywords within this custom DSL and how they impact the UI. None, some, or all can be used on a given variable to change its behavior in the UI.

## Group
Some variables are connected to each other and should be presented together. For example disk type and disk size are both related to the storage disk. The `group` field is a number. RAD Lab UI parses the `group` field and **groups variables by this number** and also **orders the pages** (of grouped variables) by this as well.

**(Example)** Both variables will be presented on the 3rd page:
```terraform
variable "network_name" {
  description = "Name of the network to be created. {{UIMeta group=3 }}"
  type        = string
  default     = "vpc"
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the resources. {{UIMeta group=3 }}"
  type        = string
  default     = "subnet"
}
```

:::caution
`group=0` is a special group--these variables will only be shown to Admin users. Users deploying a module will start on `group=1`
:::

## Order
Within a [group](#group), the order of the variables is determined by the `order` keyword. It is a whole number and sorted in ascending order (smallest first).

**(Example)** `subnet_name` will be shown before `network_name`:
```terraform
variable "network_name" {
  description = "Name of the network to be created. {{UIMeta group=3 order=2 }}"
  type        = string
  default     = "vpc"
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the resources. {{UIMeta group=3 order=1 }}"
  type        = string
  default     = "subnet"
}
```

## Options
Some variables are presented as a dropdown of options instead of a free-form input. The `options` keyword is a comma-delimted list of options the user can select from. Only one option is selectable (no multi-select).

**(Example)** A dropdown with three options (50, 100, and 500) will be displayed to the user
```terraform
variable "boot_disk_size_gb" {
  description = "The size of the boot disk (GB) {{UIMeta options=50,100,500 }}"
  type        = number
  default     = 100
}
```

## Updatesafe
After a module has been deployed (the project created and resources created within it), some Terraform updates can be **destructive**. To warn the users that they may be performing a potentially destructive action, the `updatesafe` key word is added (or omitted) to the `UIMeta`.

Any time a user makes an update to an existing deployment, the `updatesafe` values are checked. If **ANY** of the changed variables do **NOT** have the `updatesafe` keyword, the user will be warned that they likely will lose data by applying the update. Put another way, only if **ALL** the changed variables are `updatesafe` will the prompt be skipped.

:::danger
Ensure you backup any data before performing a destructive action.
:::
