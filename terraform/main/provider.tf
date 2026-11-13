provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Project     = var.Project-tag
      Owner       = var.Owner-tag
      Environment = var.Environment-tag
    }
  }
}