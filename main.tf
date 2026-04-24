provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "my_cicd_securitygroup" {
  description = "My custom security group"
  name        = "my_cicd_securitygroup"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  description       = "Enable SSH port past the EC2 firewall"
  security_group_id = aws_security_group.my_cicd_securitygroup.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  description       = "Allow all outbound traffic from the EC2 instance"
  security_group_id = aws_security_group.my_cicd_securitygroup.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "my_terraform_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  key_name      = var.ec2_ssh_key
  user_data     = file("install_docker.sh")
  tags = {
    Name = var.ec2_name
  }
  vpc_security_group_ids = [aws_security_group.my_cicd_securitygroup.id]
}
