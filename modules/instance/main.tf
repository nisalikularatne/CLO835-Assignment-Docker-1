#resource "aws_default_vpc" "default" {}
#data "aws_caller_identity" "current" {}
#resource "aws_subnet" "public"{
#  vpc_id = aws_default_vpc.default.id
#  cidr_block = "172.31.128.0/20"
#
#  tags = {
#    Name = "public-subnet"
#  }
#}
#data "aws_region" "current" {}
#
#locals {
#  prefix = "docker-dev-containers"
#  region = data.aws_region.current.name
#}
#
#module "instance" {
#  source = "cloudposse/ec2-instance/aws"
#  # Cloud Posse recommends pinning every module to a specific version
#  # version     = "x.x.x"
#  ssh_key_pair                = var.ssh_key_pair
#  ami = data.aws_ami.amazon_linux.id
#  instance_type               = var.instance_type
#  vpc_id                      = aws_default_vpc.default.id
#  instance_profile = "EMR_EC2_DefaultRole"
#  subnet                      = aws_subnet.public.id
#  associate_public_ip_address = true
#  name                        = "ec2"
#  user_data = <<EOF
##!bin/bash
#      "sudo yum install -y docker"
#      "sudo service docker start"
#      "sudo usermod -aG docker $(whoami)"
#      "aws ecr get-login-password | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
#      "docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-database-repo:latest"
#      "docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest"
#      "docker run --name my-app -d -p 8080:80 ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest"
#EOF
#}
#data "aws_ami" "amazon_linux" {
#  most_recent = true
#  owners = ["amazon"]
#  filter {
#    name   = "name"
#    values = ["amzn2-ami-hvm-2.*-x86_64-gp2"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#}
resource "aws_default_vpc" "default" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
provider "aws" {
  region = "us-east-1"
}

# Use remote state to retrieve the data
data "terraform_remote_state" "networking" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                    // Bucket from where to GET Terraform State
    key    = "dev-networking/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                        // Region where bucket created
  }
}
data "terraform_remote_state" "sg" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                        // Bucket from where to GET Terraform State
    key    = "dev-security-group/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                            // Region where bucket created
  }
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
  prefix      = "docker-dev-containers"
  region      = data.aws_region.current.name
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.latestAmazonLinux.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet
  vpc_security_group_ids      = [data.terraform_remote_state.sg.outputs.ec2_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"
  user_data                   = <<EOF
#!/bin/bash
sudo su
sudo yum install -y docker
sudo service docker start
sudo docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) 061186295720.dkr.ecr.us-east-1.amazonaws.com
sudo docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-database-repo:latest
sudo docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
sudo docker run --name my_db -d -e MYSQL_ROOT_PASSWORD=pw ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-database-repo:latest
export DBHOST=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' my_db)
echo $DBHOST
export DBPORT=3306
export DBUSER=root
export DATABASE=employees
export DBPWD=pw
export APP_COLOR=blue
first_container=my_db
# Check the status of the first container
if [ $(docker inspect -f "{{.State.Running}}" my_db) = "true" ]; then
  # Start the second container, linking it to the first container
  sudo docker run -d --name container1 --link my_db -p 8080:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
fi
sudo docker run -d --name container1 -p 8080:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
export APP_COLOR=green
sudo docker run -d --name container2 -p 8081:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
export APP_COLOR=pink
sudo docker run -d --name container3 -p 8082:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest

EOF

  lifecycle {
    create_before_destroy = true
  }
  key_name = var.linux_key_ec2
  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}
# Data source for AMI id
data "aws_ami" "latestAmazonLinux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
