# Define ECR repo to store database images
resource "aws_ecr_repository" "database" {
  name         = "docker-${var.env}-containers-database-repo"
  force_delete = true
  tags = {
    Name = "docker-${var.env}-containers-database-repo"
  }
}

# Define ECR repo to store application images
resource "aws_ecr_repository" "application" {
  name         = "docker-${var.env}-containers-application-repo"
  force_delete = true
  tags = {
    Name = "docker-${var.env}-containers-application-repo"
  }
}
