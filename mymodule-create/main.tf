#################
#  Root Module  #
#################

provider "aws" {
  region = "ap-northeast-2"
}

# 1) VPC & Subnet & Routing 구성 (net 모듈)
module "net" {
  source = "./modules/net"

  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"
}

# 2) EC2 생성 (ec2 모듈)
module "ec2" {
  source    = "./modules/ec2"
  vpc_id    = module.net.vpc_id
  subnet_id = module.net.subnet_id
}
