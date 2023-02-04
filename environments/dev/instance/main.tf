module "ec2-dev" {
  source        = "../../../modules/instance"
  bucket_name   = var.bucket_name
  instance_type = var.instance_type
  linux_key_ec2 = var.linux_key_ec2
  prefix        = var.prefix
}

