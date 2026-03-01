# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-2"
}

# ec2.tf
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "app-server-1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  key_name = aws_key_pair.admin-ssh.key_name
  vpc_security_group_ids = [
    aws_security_group.app-servers-sg.id
  ]

  tags = {
    Name = "app-backend-1"
  }
}

resource "aws_key_pair" "admin-ssh" {
  key_name   = "devops-main-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# sg.tf
  resource "aws_security_group" "app-servers-sg" {
  name        = "app-servers-sg"
  description = "Allow SSH and output traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
