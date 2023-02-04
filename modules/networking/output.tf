output "vpc_id" {
  value = aws_default_vpc.default.id
}
output "public_subnet" {
  value = aws_subnet.publicSubnet.id
}
