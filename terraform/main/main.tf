locals {
  name_prefix = "${var.Project-tag}-${var.Environment-tag}"
}

module "network" {
  source      = "../modules/network"
}