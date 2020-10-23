terraform {
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "eu-central-1"
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "server_certificate_name" {
  type = string
}

variable "client_certificate_name" {
  type = string
}

variable "client_cidr" {
  type = string
}

resource "aws_security_group" "client_vpn" {
  name        = "shared-vpn-access"
  description = "shared-vpn-access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shared-vpn-access"
  }
}

module "client-vpn" {
  source = "../../"

  name                    = var.name
  security_group_name     = aws_security_group.client_vpn.name
  server_certificate_name = var.server_certificate_name
  client_certificate_name = var.client_certificate_name
  client_cidr             = var.client_cidr
  subnet_ids              = var.subnet_ids
  transport_protocol      = "TCP"

  depends_on = [
    aws_security_group.client_vpn
  ]
}

output "routes" {
  value = module.client-vpn.routes
}
