variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "alb_sg_id" {}
variable "target_group_arn" {}
