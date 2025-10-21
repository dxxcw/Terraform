##################
#  EC2 Instance  #
##################
data "aws_ami" "amz2023ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "main-instance" {
  count         = var.ec2_count
  ami           = data.aws_ami.amz2023ami.id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id 
  tags          = var.instance_tag
}