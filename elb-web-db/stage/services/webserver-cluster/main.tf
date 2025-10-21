############################################
# ALB - TG(ASG) - EC2
############################################

# 1) VPC, Subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2) TG, SG, LT(Launch Template), ASG
# Target Group
resource "aws_lb_target_group" "myalb-tg" {
  name     = "myalb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# Security Group
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080/tcp inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_8080"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Remote state
data "terraform_remote_state" "myRemoteState" {
  backend = "s3"
  config = {
    bucket = "mybucket-1994-0622-0523"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

# Launch Template
resource "aws_launch_template" "myLT" {
  name                   = "myLT"
  image_id               = "ami-0cfde0ea8edd312d4" 
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = base64encode(templatefile("user-data.sh", {
    db_address  = data.terraform_remote_state.myRemoteState.outputs.db_address
    db_port     = data.terraform_remote_state.myRemoteState.outputs.db_port
    server_port = 8080
  })) 
}

# Auto Scaling Group
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.myalb-tg.arn]
  desired_capacity    = 2
  max_size            = 10
  min_size            = 2

  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
}

# 3) ALB, ALB listener, ALB listener rules
# Application Load Balancer
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_8080.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false
}

# ALB listener
resource "aws_lb_listener" "myalb-listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb-tg.arn
  }
}

# ALB listener Rule
resource "aws_lb_listener_rule" "myalb-listener-rule" {
  listener_arn = aws_lb_listener.myalb-listener.arn
  priority     = 100

condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb-tg.arn
  }

  
}