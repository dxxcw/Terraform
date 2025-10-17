######################################################
# Mini Project 1 - Developer Envirnmnet Configuration
#-----------------------------------------------------
# 1. VPC
#   * VPC 생성
#   * Internet Gateway 생성 및 VPC 연결
# 2. Public Subnet
# 3. Routing Table
#   * Public Subnet에 대한 Route Table 생성
#   * Public Subnet에 Routing Table 연결
# 4. EC2
#   * Security Group 생성
#   * EC2 생성
######################################################

# 1. VPC
# VPC 생성
# * enable_dns_support = true
# * enabel_dns_hostname = true
# * VPC cidr_block = 10.123.0.0/16
resource "aws_vpc" "myVPC"{
  cidr_block           = "10.123.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# Internet Gateway 생성 및 VPC 연결
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# 2. Public Subnet
# * map_public_ip_on_launch = true
# * public subnet cidr_block = 10.123.1.0/24
resource "aws_subnet" "myPubSN" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

# 3. Routing Table
# Public Subnet에 대한 Route Table 생성
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

# Public Subnet에 Routing Table 연결
resource "aws_route_table_association" "myPubRT-assoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

# 4. EC2
# Security Group 생성
# * Inbound Rule: ALL or SSH(22), HTTP(80), HTTPS(443)
# * Outbound Rule: ALL
resource "aws_security_group" "allow_all_traffic" {
  name        = "allow_all_traffic"
  description = "Allow All Inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "allow_all_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_ingress_traffic" {
  security_group_id = aws_security_group.allow_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic" {
  security_group_id = aws_security_group.allow_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



# EC2 생성
# * AMI: Amazon Linux 2023 AMI
# * Instance Type: t3.micro
# * Key Pair: myUSkeypair
# * Security Group: allow_all_traffic
data "aws_ami" "ubuntu2024ami" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]
}

# KeyPair 생성
resource "aws_key_pair" "myDeveloperKey" {
  key_name   = "myDeveloperKey"
  public_key = file("~/.ssh/devkey.pub")
}

resource "aws_instance" "myEC2" {
  ami                    = data.aws_ami.ubuntu2024ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_id              = aws_subnet.myPubSN.id
  key_name               = aws_key_pair.myDeveloperKey.key_name

  tags = {
    Name = "myEC2"
  }
}

