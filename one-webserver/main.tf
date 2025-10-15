provider "aws" {
  region = var.myRegion
}

resource "aws_instance" "example" {
  ami                         = var.myAMI_ubuntu2204
  instance_type               = var.my_instance_type
  vpc_security_group_ids      = [aws_security_group.allow_8080.id]
  user_data_replace_on_change = var.my_userdata_changed
  tags                        = var.my_webserver_tag
  user_data                   = <<EOF
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p 8080 &
EOF    

  /* user_data = <<EOF
#!/bin/bash
sudo apt -y install apache2
echo "WEB" | sudo tee /var/www/html/index.html
sudo systemctl enable --now apache2
EOF
&& 80port로 변경 */
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic and all outbound traffic"
  tags        = var.my_sg_tag
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.my_http_port
  to_port           = var.my_http_port
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}