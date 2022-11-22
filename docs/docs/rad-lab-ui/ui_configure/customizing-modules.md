---
sidebar_position: 2
---

# Customizing Modules

After you have [forked the official RAD Lab repository](../../ui_installation/source-control), you can customize it to match your organization's needs.

## Changing Default Values
In your forked repository, you can simply go to the `/modules/[specific_module]/variables.tf` file and change the variable's `default` value.

## Changing Layout
Editing the [UI Meta](../ui-meta) is the quickest way change the grouping, ordering, and dropdown selections of variables.

## Examples

### Creating T-Shirt Sizing
If you'd like to offer `small`, `medium`, and `large` deployment options to your data scientist users, you can do the following:
- Copy the `/modules/data_science` module into three modules
  - `/modules/data_science_small`
  - `/modules/data_science_medium`
  - `/modules/data_science_large`
- Within each of these modules, [change the default values](#changing-default-values) to correspond with the t-shirt sizing
  - **(Example)** 
    - `/modules/data_science_small` may have 50GB disk and use a small machine type
    - `/modules/data_science_large` may have 1000GB disk, use a large machine type, and have an attached GPU
- [Publish the modules](../../ui_installation/publishing-modules/) for your users
- A user will see the three options and can easily pick the size that works for them
