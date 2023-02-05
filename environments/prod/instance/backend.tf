terraform {
  backend "s3" {
    bucket = "dev-clo835-docker-assignment1"
    key    = "dev-ec2-instance/terraform.tfstate"
    region = "us-east-1"
  }
}
