output "vpc_id" {
  description = "Created VPC ID"
  value       = module.net.vpc_id
}

output "subnet_id" {
  description = "Created Subnet ID"
  value       = module.net.subnet_id
}

output "instance_public_ip" {
  description = "EC2 Instance Public IP"
  value       = module.ec2.instance_public_ip
}
