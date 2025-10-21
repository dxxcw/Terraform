output "db_address" {
    value = aws_db_instance.myDBinstance.address
}

output "db_port" {
    value = aws_db_instance.myDBinstance.port
}