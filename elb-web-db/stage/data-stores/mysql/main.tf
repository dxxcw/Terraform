terraform {
  backend "s3" {
    bucket = "mybucket-1994-0622-0523"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "myDynamoDBTable"
  }
}

provider "aws" {
    region = "us-east-2"
}

# MySQL DB Instance 설정
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "myDBinstance" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  
  username             = var.dbuser
  password             = var.dbpassword
}

