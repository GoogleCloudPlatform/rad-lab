# Cloud NAT Module

Simple Cloud NAT management, with optional router creation.

## Example

```hcl
module "nat" {
  source         = "./tf_modules/net-cloudnat"
  project_id     = "my-project"
  region         = "europe-west1"
  name           = "default"
  router_network = "my-vpc"
}
# tftest modules=1 resources=2
```
<!-- BEGIN TFDOC -->