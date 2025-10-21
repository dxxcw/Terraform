#################
#  root module  #
#################

# AWS Provider
provider "aws" {
    region = "ap-northeast-2"
}

# Module : myvpc
module "myvpc" {
    source      = "../modules/vpc"

    # Optional Parameters
    vpc_cidr    = "192.168.0.0/24"
    subnet_cidr = "192.168.0.0/25"
}

# Module : ec2
module "myinstance" {
    source = "../modules/ec2"

    # Requred Parmeter
    subnet_id = module.myvpc.subnet_id
    ec2_count = 1
}