locals {
  name_prefix = "${var.Project-tag}-${var.Environment-tag}"
}

module "network" {
    source = "../modules/network"
    name_prefix = local.name_prefix
}