module "alb-dev" {
  source      = "../../../modules/alb"
  bucket_name = var.bucket_name
  prefix      = var.prefix
}

