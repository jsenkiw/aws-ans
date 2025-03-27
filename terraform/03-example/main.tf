terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "main-vpc" {
  cidr_block       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_subnet" "aza01-snet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "aza02-snet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2a"
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table_association" "rt-public-aza" {
  subnet_id      = aws_subnet.aza01-snet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rt-private-aza" {
  subnet_id      = aws_subnet.aza02-snet.id
  route_table_id = aws_route_table.private-rt.id
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
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "dmza-nic" {
  subnet_id       = aws_subnet.aza01-snet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.ssh-only.id]
}

resource "aws_eip" "dmza-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.dmza-nic.id
  associate_with_private_ip = "10.0.1.10"
}

resource "aws_network_interface" "dmzb-nic" {
  subnet_id       = aws_subnet.aza02-snet.id
  private_ips     = ["10.0.2.20"]
  security_groups = [aws_security_group.ssh-only.id]
}

resource "aws_eip" "dmzb-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.dmzb-nic.id
  associate_with_private_ip = "10.0.2.20"
}


resource "aws_instance" "dmza-host" {
  ami             = "ami-0e56583ebfdfc098f"
  instance_type   = "t2.micro"
  key_name        = "aws-eu-w2.default"
  
  network_interface {
    network_interface_id = aws_network_interface.dmza-nic.id
    device_index = 0
  }
  
}

resource "aws_instance" "dmzb-host" {
  ami             = "ami-0e56583ebfdfc098f"
  instance_type   = "t2.micro"
  key_name        = "aws-eu-w2.default"
  
  network_interface {
    network_interface_id = aws_network_interface.dmzb-nic.id
    device_index = 0
  }
  
}

 
output "dmza-public-ip" {
  value       = aws_instance.dmza-host.public_ip
  description = "Public IP address DMZ Host"
}

output "dmza-public-dns" {
  value       = aws_instance.dmza-host.public_dns
  description = "Public DNS Host"
}

output "dmzb-public-ip" {
  value       = aws_instance.dmzb-host.public_ip
  description = "Public IP address DMZ Host"
}

output "dmzb-public-dns" {
  value       = aws_instance.dmzb-host.public_dns
  description = "Public DNS Host"
}