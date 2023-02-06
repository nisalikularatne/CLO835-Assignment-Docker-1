terraform {
  backend "s3" {
    bucket = "prod-clo835-docker-assignment1"
    key    = "prod-networking/terraform.tfstate"
    region = "us-east-1"
  }
}
