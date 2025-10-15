##########################
#  Output Variable 정의   #
##########################
output "myweb_public_ip" {
  value       = aws_instance.example.public_ip
  description = "My webserver publicip"
}

# [FILE] terraform.tfstate
# tf state list
# tf state show aws_instance.example
# -> public_ip, public_dns
# -> aws_instance.example.public_dns

output "myweb_public_dns" {
  description = "My Webservice Public DNS"
  value       = aws_instance.example.public_dns
}

# tf output
# tf output myweb_public_dns
# curl $(tf output -raw myweb_public_dns):8080 