# Provider 설정
provider "aws" {
    region = "us-east-2"
}

# VPC 생성
resource "aws_vpc" "main" {
    cidr_block = "190.160.0.0/16"
    instance_tenancy = "default"
    tags = {
        Name = "Main"
        Location = "Seoul"
    }
}

# Subnet 생성
resource "aws_subnet" "subnet1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "190.160.1.0/24"

    tags = {
        Name = "Subnet1"
    }
}
