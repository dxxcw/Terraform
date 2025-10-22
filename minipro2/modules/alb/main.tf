############################################
# ALB Security Group
############################################
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  name   = "alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

############################################
# ALB
############################################
resource "aws_lb" "alb" {
  name               = "3tier-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
  tags = { Name = "3tier-alb" }
}

############################################
# Target Group
############################################
resource "aws_lb_target_group" "tg" {
  name     = "3tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
}

############################################
# Listener
############################################
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
