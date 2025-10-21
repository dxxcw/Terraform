variable "instance_tag" {
    default = {
        Name = "main-instance"
  }
}

variable "subnet_id" {
    description = "Subnet ID"
    type        = string
}

variable "ec2_count" {
    description = "EC2 Instance Count"
    type        = number

}