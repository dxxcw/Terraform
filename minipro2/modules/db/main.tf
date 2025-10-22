############################################
# DB Security Group
############################################
resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  name   = "db-sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg" }
}

############################################
# DB Subnet Group
############################################
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds-subnet"
  subnet_ids = var.private_subnets
  tags = { Name = "rds-subnet" }
}

############################################
# RDS Instance
############################################
resource "aws_db_instance" "db" {
  identifier             = "mydb"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "Password123!"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = true
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = { Name = "rds-db" }
}
