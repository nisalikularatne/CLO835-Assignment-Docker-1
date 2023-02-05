module "ec2SG-dev" {
  source       = "../../../modules/securityGroup"
  env          = var.env
  prefix       = var.prefix
  default_tags = var.default_tags
  bucket_name  = var.bucket_name
}


