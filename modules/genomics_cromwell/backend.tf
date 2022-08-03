terraform {
  backend "gcs" {
    //    bucket = "" # This will be passed as backend-config variables in the terraform init. See cloubuild.genomics_cromwell.yaml.
    //    prefix = "" # This will be passed as backend-config variables in the terraform init. See cloubuild.genomics_cromwell.yaml.
  }
}
