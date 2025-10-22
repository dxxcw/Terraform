data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################################
# EC2 Security Group
############################################
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id
  name   = "web-sg"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

############################################
# Launch Template
############################################
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt"
  image_id      = data.aws_ami.amzn2.id
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    echo "<h1>3Tier Web Server</h1>" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
  EOF
  )

  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = var.public_subnets

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}
