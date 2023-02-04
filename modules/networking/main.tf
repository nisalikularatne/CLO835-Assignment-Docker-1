resource "aws_default_vpc" "default" {}
data "aws_caller_identity" "current" {}
# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
}
resource "aws_subnet" "publicSubnet" {
  vpc_id     = aws_default_vpc.default.id
  cidr_block = var.cidr
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-subnet"
    }
  )
}
