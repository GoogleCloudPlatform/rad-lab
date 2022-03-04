# Project

The purpose of this module is to create a GCP project.  

## Examples

### Create the minimal setup

```hcl
module "project" {
  src = "./project"
  
  billing_account_id  = "xyz-xyz-xyz"
  parent              = "folders/123456789"
  project_services    = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ] 
}
```

### Use existing project
```hcl
module "project" {
  src = "./project"
  
  billing_account_id  = "xyz-xyz-xyz"
  parent              = "folders/123456789"
  project_id          = "existing-project-id"
}
``` 