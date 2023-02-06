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
    bucket = var.bucket_name                     // Bucket from where to GET Terraform State
    key    = "prod-networking/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                         // Region where bucket created
  }
}
data "terraform_remote_state" "sg" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                         // Bucket from where to GET Terraform State
    key    = "prod-security-group/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                             // Region where bucket created
  }
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  name_prefix = "${var.prefix}-${var.env}"
  prefix      = "docker-prod-containers"
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
sudo docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
sudo docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-database-repo:latest
sudo docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
sudo docker network create mynetwork
sudo docker run --name my_db --net mynetwork -d -e MYSQL_ROOT_PASSWORD=pw ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-database-repo:latest
export DBHOST=$(sudo docker inspect --format '{{ .NetworkSettings.Networks.mynetwork.IPAddress }}' my_db)
sleep 60
echo $DBHOST
export DBPORT=3306
export DBUSER=root
export DATABASE=employees
export DBPWD=pw
export APP_COLOR=blue
first_container=my_db
# Check the status of the first container
sudo docker run -d --name blue --net mynetwork -p 8081:8080  -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD -e ROUTE="/blue" ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
export APP_COLOR=pink
sleep 30
sudo docker run --net mynetwork -d --name pink -p 8082:8080  -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD -e ROUTE="/green" ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest
sleep 30
export APP_COLOR=lime
sudo docker run -d --name lime --net mynetwork -p 8083:8080  -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD -e ROUTE="/pink" ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-application-repo:latest

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
