variable "vpc_id" {}
variable "private_subnets" {
  type = list(string)
}
variable "ec2_sg_id" {}
