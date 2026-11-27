locals {
  name_prefix = "${var.Project-tag}-${var.Environment-tag}"
}

data "aws_ecr_repository" "devsecops_dev_ecr_repo" {
  name = "${local.name_prefix}-ecr-repo"
}

module "network" {
  source      = "../modules/network"
  name_prefix = local.name_prefix
}

module "ecs" {
  source           = "../modules/ecs"
  name_prefix      = local.name_prefix
  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_id
  image_uri        = "${data.aws_ecr_repository.devsecops_dev_ecr_repo.repository_url}:${var.image_tag}"
}

#test checkov cicd