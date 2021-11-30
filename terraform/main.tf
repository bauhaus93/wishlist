terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "tls_private_key" "wishlist_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wishlist_key_pair" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.wishlist_ssh_key.public_key_openssh
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0bd99ef9eccfee250"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.wishlist_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = var.instance_name
  }
}


resource "aws_security_group" "main" {
  egress = [
    {
      description      = "Allow all outgoing"
      cidr_blocks      = ["0.0.0.0/0", ]
      ipv6_cidr_blocks = ["::/0"]
      from_port        = 0
      to_port          = 0
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      description      = "Allow SSH"
      cidr_blocks      = ["0.0.0.0/0", ]
      ipv6_cidr_blocks = ["::/0"]
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      }, {
      description      = "Allow HTTP"
      cidr_blocks      = ["0.0.0.0/0", ]
      ipv6_cidr_blocks = ["::/0"]
      protocol         = "tcp"
      from_port        = 80
      to_port          = 80
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow TLS"
      cidr_blocks      = ["0.0.0.0/0", ]
      ipv6_cidr_blocks = ["::/0"]
      protocol         = "tcp"
      from_port        = 443
      to_port          = 443
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }


  ]
}
