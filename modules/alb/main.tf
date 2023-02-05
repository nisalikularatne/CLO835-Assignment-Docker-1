# Use remote state to retrieve the data
data "terraform_remote_state" "networking" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                    // Bucket from where to GET Terraform State
    key    = "dev-networking/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                        // Region where bucket created
  }
}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow traffic from the internet to the ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
  name            = "main"
  internal        = false
  security_groups = [aws_security_group.alb.id]
  subnets         = [data.terraform_remote_state.networking.outputs.public_subnet, "subnet-0035ae5a98aa94d29"]
}

resource "aws_alb_listener" "example" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_alb_target_group.example-1.arn
  }
}

resource "aws_alb_target_group" "example-1" {
  name     = "example-target-group-1"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  port     = 8080
  protocol = "HTTP"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_alb_target_group" "example-2" {
  name     = "example-target-group-2"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  port     = 8081
  protocol = "HTTP"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_alb_target_group" "example-3" {
  name     = "example-target-group-3"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}
resource "aws_alb_listener_rule" "example-1" {
  listener_arn = aws_alb_listener.example.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.example-1.arn
  }

  condition {
    path_pattern {
      values = ["/container1/*"]
    }
  }
}

resource "aws_alb_listener_rule" "example-2" {
  listener_arn = aws_alb_listener.example.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.example-2.arn
  }

  condition {
    path_pattern {
      values = ["/container2/*"]
    }
  }
}

resource "aws_alb_listener_rule" "example-3" {
  listener_arn = aws_alb_listener.example.arn


  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.example-3.arn
  }

  condition {
    path_pattern {
      values = ["/container3/*"]
    }
  }
}
