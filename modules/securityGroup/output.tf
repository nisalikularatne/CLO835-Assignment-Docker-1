# Add output variables
output "ec2_sg_id" {
  value = aws_security_group.ec2SG.id
}

