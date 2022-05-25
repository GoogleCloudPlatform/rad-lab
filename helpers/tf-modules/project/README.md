# Project Module

The module implements the creation and management of one GCP project, including organization policies and IAM policies.   The module allows you to use an existing project, which is useful if project creation permissions are assigned to a different team.

## Examples

### Organization Policies

```hcl
module "project" {
  source              = "./modules/project"
  billing_account_id  = "ABCD-ABCD-ABCD-ABCD"
  name                = "project-example"
  parent              = "folders/1234567890"
  project_apis        = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com"
  ]
  
  org_policy_bool     = {
    "constraints/compute.skipDefaultNetworkCreation" = true
  }
  
  org_policy_list = {
    "constraints/compute.restrictVpcPeering" : {
      inherit_from_parent = false
      suggested_value     = null
      status              = true
      values              = null
    }
  }
}
```

### Existing Projects

```hcl
module "project" {
  source              = "./modules/project"
  billing_account_id  = "ABCD-ABCD-ABCD-ABCD"
  name                = "existing-proj-id"
  create_project      = false
  parent              = "folders/1234567890"
}
```

<!-- BEGIN TFDOC -->

<!-- END TFDOC -->