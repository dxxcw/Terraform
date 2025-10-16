########################
# Provider 설정
########################
# terraform 설정
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.16.0"
    }
  }
}

# Provider 설정
provider "aws" {
    region = "us-east-2"
}

########################
# Resource 설정
########################
# EC2 인스턴스 AMI ID를 위한 Data Source 조회
# Amazon Linux 2023 AMI
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

data "aws_ami" "amazonLinux" {
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

# EC2 생성
resource "aws_instance" "myInstance" {
  ami                    = data.aws_ami.amazonLinux.id
  instance_type          = "t3.micro"
  key_name               = "myUSkeypair"
  vpc_security_group_ids = [aws_security_group.mySG.id]

  tags = {
    Name = "myInstance"
  }
}

# SG 및 inbound/outbound rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG" {
  name        = "allow_ssh"
  description = "Allow 22/tcp inbound traffic and all outbound traffic"

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

