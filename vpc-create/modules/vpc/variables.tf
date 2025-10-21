variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "instance_tenancy" {
    default = "default"
}

variable "vpc_tag" {
    default = {
        Name = "main_vpc"
  }
}

variable "subnet_cidr" {
    default = "10.0.1.0/24"
}

variable "subnet_tag" {
    default = {
        Name = "main_subnet"
  }
}