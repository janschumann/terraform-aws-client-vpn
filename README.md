# Terraform module for AWS client VPN endpoints

Currently only `certificate-authentication` is supported.

The server and client certificates need to be created and imported to ACM 
before using this module. 

https://labrlearning.medium.com/remote-access-to-aws-with-the-client-vpn-6c43cd740b8  

## Usage

```hcl

locals {
  subnets = {
    "eu-west-1a" = "10.100.10.0/24"
    "eu-west-1b" = "10.100.11.0/24" 
  }
}

resource "aws_vpc" "test" {
  cidr_block = "10.100.0.0/16"
}

resource "aws_subnet" "target" {
  for_each = local.subnets

  vpc_id            = aws_vpc.test.id
  cidr_block        = each.value
  availability_zone = each.key
}

resource "aws_security_group" "client_vpn" {
  name        = "shared-vpn-access"
  description = "shared-vpn-access"
  vpc_id      = aws_vpc.test.id

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
  source  = "janschumann/client-vpn/aws"
  version = "0.1.0"

  name                    = "testvpn"
  vpc_id                  = aws_vpc.test.id
  security_group_name     = aws_security_group.client_vpn.name
  server_certificate_name = "vpn-server" 
  client_certificate_name = "von-client"
  client_cidr             = "10.100.0.0/22"
  subnet_ids              = [
    aws_subnet.target["eu-west-1a"].id,
    aws_subnet.target["eu-west-1b"].id
  ]
  transport_protocol      = "TCP"
}
```
 
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| aws | ~> 2.7 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_ca | The CA cert for client authentication. Only necessary if write\_ovpn\_config is set to true. | `string` | `""` | no |
| client\_certificate\_name | The name of the client certificate in AWS ACM. | `string` | n/a | yes |
| client\_cidr | The address space to use for VPN clients. | `string` | n/a | yes |
| name | The name of this VPN. | `string` | n/a | yes |
| security\_group\_name | The security group name to access the VPN server. | `string` | n/a | yes |
| server\_certificate\_name | The name of the server certificate in AWS ACM. | `string` | n/a | yes |
| subnets | The subnets to associate with this VPN. | `list(string)` | n/a | yes |
| vpc\_id | The VPC id of the remote network. | `string` | n/a | yes |
| write\_ovpn\_config | Write an openVPN config file. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_cidr | The address space of VPN clients. |
| dns\_name | The dns name of the VPN server. |
| routes | A list of route information in the form {network, netmask}. |

