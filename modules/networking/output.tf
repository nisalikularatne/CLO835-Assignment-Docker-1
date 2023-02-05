output "vpc_id" {
  value = aws_default_vpc.default.id
}
output "public_subnet" {
  value = aws_subnet.publicSubnet.id
}
output "default_az_1" {
  value = aws_default_subnet.default_az1.id
}
