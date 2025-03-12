terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "main-vpc" {
  cidr_block       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "main.vpc"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "internet.gw"
  }
}

resource "aws_subnet" "aza01-snet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "snet.aza.10.0.1.0"
  }
}

resource "aws_route_table" "dmz-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "dmz.rt"
  }
}

resource "aws_route_table_association" "rt-aza" {
  subnet_id      = aws_subnet.aza01-snet.id
  route_table_id = aws_route_table.dmz-rt.id
}

resource "aws_security_group" "ssh-only" {
  name = "ssh.sgrp"
  vpc_id = aws_vpc.main-vpc.id
  
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
  
  tags = {
    Name = "allow.ssh"
  }
}

resource "aws_instance" "dmza-host" {
  ami           = "ami-0e56583ebfdfc098f"
  instance_type = "t2.micro"
  key_name = "aws-eu-w2.default"
  vpc_security_group_ids = [aws_security_group.ssh-only.id]
  subnet_id = aws_subnet.aza01-snet.id
  associate_public_ip_address = true
  
  tags = {
  Name = "dmza.host"  
  }
}  
  
output "dmz-public-ip" {
  value       = aws_instance.dmza-host.public_ip
  description = "Public IP address DMZ Host"
}