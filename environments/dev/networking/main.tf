# Module to deploy basic networking
module "vpc-dev" {
  source       = "../../../modules/networking"
  env          = var.env
  prefix       = var.prefix
  default_tags = var.default_tags
}
