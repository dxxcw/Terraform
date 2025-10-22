###################
#  EC2 Module     #
###################

# 최신 Amazon Linux 2023 AMI 조회
data "aws_ami" "amz2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "web-sg"
  }
}

# 2. Key Pair
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("~/.ssh/devkey.pub")   
}

# 3. EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amz2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.mykey.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Terraform EC2 Module</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "ec2-module-instance"
  }
}
