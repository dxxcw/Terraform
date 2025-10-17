####################################
# 1. ASG 생성
#-----------------------------------
# 1) 보안 그룹 생성
# 2) 시작 템플릿 생성
# 3) AutoScaling Group 생성
####################################
# 2. ALB 생성
#-----------------------------------
# 1) 보안 그룹 생성
# 2) Target Group 생성
# 3) ALB 구성
# 4) ALB listener 구성
# 5) ALB listener rule 구성
####################################

# 1. ASG 생성
# 1) 보안 그룹 생성
# Default VPC
data "aws_vpc" "default" {
  default = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "my_ASG_SG" {
  name        = "my_ASG_SG"
  description = "Allow HTTP & HTTPS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "my_ASG_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.my_ASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.server_http_port
  to_port           = var.server_http_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_443" {
  security_group_id = aws_security_group.my_ASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.server_https_port
  to_port           = var.server_https_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.my_ASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Amazon Linux 2023 AMI
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
data "aws_ami" "amz2023ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

# 2) Launch Template for Web Server
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "myLT" {
  name                   = "myLT"
  image_id               = data.aws_ami.amz2023ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_ASG_SG.id]

  # https://developer.hashicorp.com/terraform/language/functions/filebase64
  user_data              = filebase64("./LT_user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# 3) AutoScaling Group 생성
# Subnet for ASG
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ASG for Web Service
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default_subnets.ids
  desired_capacity    = 2
  min_size            = var.instance_min_size
  max_size            = var.instance_max_size

# [중요]
  target_group_arns = [aws_lb_target_group.myTG.arn]
  depends_on = [aws_lb_target_group.myTG]

  launch_template {
    id      = aws_launch_template.myLT.id
  }
}

# 2. ALB 생성
# 1) 보안 그룹 생성 (생략)
# 2) Target Group 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# resource "aws_lb_target_group" "myTG" {
#   name        = "myALB-TG"
#   target_type = "alb"
#   port        = var.server_http_port
#   protocol    = "TCP"
#   vpc_id      = data.aws_vpc.default.id
# }

# 2) Target Group 생성 (수정 완료)
resource "aws_lb_target_group" "myTG" {
  name        = "myALB-TG"
  target_type = "instance"         
  port        = var.server_http_port
  protocol    = "HTTP"            
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/"      
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 3) ALB 구성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "myALB" {
  name                       = "myALB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.my_ASG_SG.id]
  subnets                    = data.aws_subnets.default_subnets.ids
  # enable_deletion_protection = true
}

# 4) ALB listener 구성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "myALB_listener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = var.server_http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code  = "404"
    }
  }
}

# 5) ALB listener rule 구성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "myALB_listener-rule" {
  listener_arn = aws_lb_listener.myALB_listener.arn
  priority     = 100

 
  condition {
    path_pattern {
      values = ["*"]
    }
  }

   action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }
}
