############################################
# Provider
############################################
provider "aws" {
  region = var.aws_region
}

############################################
# Network Module
############################################
module "network" {
  source = "./modules/network"
}

############################################
# ALB Module
############################################
module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
}

############################################
# EC2 + ASG Module
############################################
module "ec2" {
  source          = "./modules/ec2"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  alb_sg_id       = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn
}

############################################
# DB Module
############################################
module "db" {
  source          = "./modules/db"
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
  ec2_sg_id       = module.ec2.web_sg_id
}
