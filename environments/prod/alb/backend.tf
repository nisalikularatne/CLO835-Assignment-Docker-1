terraform {
  backend "s3" {
    bucket = "dev-clo835-docker-assignment1"
    key    = "dev-alb/terraform.tfstate"
    region = "us-east-1"
  }
}
