output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.main.public_ip
}
