terraform {
  backend "gcs" {
    //    bucket = "" # This will be passed as backend-config variables in the terraform init. See cloubuild.alpha_fold.yaml.
    //    prefix = "" # This will be passed as backend-config variables in the terraform init. See cloubuild.alpha_fold.yaml.
  }
}
