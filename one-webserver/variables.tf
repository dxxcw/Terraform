#########################
#  Input Variable 정의   #
#########################
variable "myRegion" {
  description = "AWS MY Region"
  type        = string
  default     = "us-east-2"
}

variable "myAMI_ubuntu2204" {
  type        = string
  default     = "ami-0cfde0ea8edd312d4"
  description = "AWS MY AMI - Ubunt 24.04 LTS(x86_64)"
}

variable "my_instance_type" {
  description = "My Ubuntu Instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_userdata_changed" {
  description = "User Data Replace on Change"
  type        = bool
  default     = true
}

variable "my_webserver_tag" {
  description = "My Webserver Tag"
  type        = map(string)
  default = {
    Name = "mywebserver"
  }
}

variable "my_sg_tag" {
  description = "My SG Tags"
  type        = map(string)
  default = {
    Name = "allow_8080"
  }
}

variable "my_http_port" {
  description = "My HTTP"
  type        = number
  default     = 8080
}


