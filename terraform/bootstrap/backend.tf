terraform {
  backend "s3" {
    bucket       = "devsecops-dev-s3"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}