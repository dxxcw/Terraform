provider "aws" {
    region = "us-east-2"
}

# S3 Bucket 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "mybucket-1994-0622-0913"

  tags = {
    Name        = "My bucket"
  }
}

# 다이나모 DB 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "terraform-locks" {
  name             = "terraform-locks"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
