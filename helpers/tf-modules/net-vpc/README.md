# VPC Module

The purpose of this module is to create a VPC network, incl. subnets.  It also allows the user to use an existing network, if necessary.

## Examples

### Simple network

```hcl
module "network" {
  source = "./net-vpc"

  project_id     = "12345678"
  network_name   = "test-vpc"

  subnets = [{
    name          = "test-vpc-sn"
    ip_cidr_range = "10.0.0.0/16"
    region        = "us-easet1"
  }]
}
```

### Secondary ranges

```hcl
module "network" {
  source = "./net-vpc"

  project_id     = "123456789"
  network_name   = "test-vpc"

  subnets = [{
    name          = "test-vpc-sn"
    ip_cidr_range = "10.0.0.0/16"
    region        = "us-east1"
    secondary_ip_range = {
      pods     = "10.200.0.0/24"
      services = "10.201.0.0/24"
    }
  }]
}
```

### Existing network
```hcl
module "network" {
  source = "../../helpers/tf-modules/net-vpc"

  project_id     = "123456789"
  create_network = false
  network_name   = var.network_name
}
```
<!-- BEGIN TFDOC -->

<!-- END TFDOC -->