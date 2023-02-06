# Use remote state to retrieve the data
data "terraform_remote_state" "networking" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                           // Bucket from where to GET Terraform State
    key    = "${var.env}-networking/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                               // Region where bucket created
  }
}
data "terraform_remote_state" "ec2" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                             // Bucket from where to GET Terraform State
    key    = "${var.env}-ec2-instance/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                                 // Region where bucket created
  }
}
data "terraform_remote_state" "sg" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = var.bucket_name                               // Bucket from where to GET Terraform State
    key    = "${var.env}-security-group/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                                   // Region where bucket created
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

resource "aws_alb" "this" {
  name            = "${var.env}-application-load-balancer"
  internal        = false
  security_groups = [aws_security_group.alb.id, data.terraform_remote_state.sg.outputs.ec2_sg_id]
  subnets         = [data.terraform_remote_state.networking.outputs.public_subnet, data.terraform_remote_state.networking.outputs.default_az_1]
  tags = {
    Name = "${var.env}-application-load-balancer"
  }
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_alb_target_group.group1.arn
  }
}

resource "aws_alb_target_group" "group1" {
  name     = "${var.env}-target-group-1"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  port     = 8080
  protocol = "HTTP"

  health_check {
    path                = "/blue"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}
#
resource "aws_alb_target_group" "group2" {
  name     = "${var.env}-target-group-2"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  port     = 8081
  protocol = "HTTP"

  health_check {
    path                = "/pink"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}
#
resource "aws_alb_target_group" "group3" {
  name     = "${var.env}-target-group-3"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  health_check {
    path                = "/lime"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_alb_listener_rule" "rule2" {
  listener_arn = aws_alb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.group2.arn
  }

  condition {
    path_pattern {
      values = ["/pink"]
    }
  }
}
resource "aws_alb_listener_rule" "rule3" {
  listener_arn = aws_alb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.group3.arn
  }

  condition {
    path_pattern {
      values = ["/lime"]
    }
  }
}
resource "aws_lb_target_group_attachment" "group1" {
  target_group_arn = aws_alb_target_group.group1.arn
  target_id        = data.terraform_remote_state.ec2.outputs.ec2_id
  port             = 8081
}
resource "aws_lb_target_group_attachment" "group2" {
  target_group_arn = aws_alb_target_group.group2.arn
  target_id        = data.terraform_remote_state.ec2.outputs.ec2_id
  port             = 8082
}
resource "aws_lb_target_group_attachment" "group3" {
  target_group_arn = aws_alb_target_group.group3.arn
  target_id        = data.terraform_remote_state.ec2.outputs.ec2_id
  port             = 8083
}

