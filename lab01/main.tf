##################################################
# 작업 순서
# - Provider 설정
# - VPC 생성
# - Internet Gateway 생성 & 연결
# - Public Subnet 생성
# - Public Routing Table 생성 & Public Subnet 연결
# - Security Group & Rule 생성
# - EC2 생성
##################################################

# 1. Provider 설정
provider "aws" {
    region = "us-east-2"
}

# 2. VPC 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "myVPC"
  }
}

# 3. Internet Gateway 생성 & 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# 4. Public Subnet 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "myPubSN" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

# 5. Public Routing Table 생성 & Public Subnet 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }


  tags = {
    Name = "myPubRT"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "myPubRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

# 6. Security Group & Rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_myweb" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "allow_http"
  }
}

# Ingress Rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_myweb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_myweb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Egress Rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  security_group_id = aws_security_group.allow_myweb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 7. EC2 생성 
resource "aws_instance" "myWEB" {
  ami                    = "ami-077b630ef539aa0b5"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.myPubSN.id
  vpc_security_group_ids = [aws_security_group.allow_myweb.id]

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    yum -y install httpd
    echo 'MyWEB' > /var/www/html/index.html
    systemctl enable --now httpd
    EOF

  tags = {
    Name = "myWEB"
  }
}