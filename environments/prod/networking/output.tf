output "vpc_id" {
  value = module.vpc-dev.vpc_id
}
output "public_subnet" {
  value = module.vpc-dev.public_subnet
}

output "default_az_1" {
  value = module.vpc-dev.default_az_1
}

