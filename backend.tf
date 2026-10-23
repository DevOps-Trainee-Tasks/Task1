terraform {
  backend "s3" {
    bucket       = "task1-tfstate-687078156188"
    key          = "task1/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
