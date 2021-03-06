# Terraform module for AWS client VPN endpoints

Currently only `certificate-authentication` is supported.

The server and client certificates need to be created and imported to ACM 
before using this module. 

https://labrlearning.medium.com/remote-access-to-aws-with-the-client-vpn-6c43cd740b8  

## Usage

```hcl
resource "aws_vpc" "test" {
  cidr_block = "10.100.0.0/16"
}

resource "aws_subnet" "target_a" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.100.10.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "target_b" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.100.11.0/24"
  availability_zone = "eu-west-1b"
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
  security_group_name     = aws_security_group.client_vpn.name
  server_certificate_name = "vpn-server" 
  client_certificate_name = "von-client"
  client_cidr             = "10.100.100.0/22"
  subnet_ids              = [
    aws_subnet.target_a.id,
    aws_subnet.target_b.id
  ]
  transport_protocol      = "TCP"
}
```
 
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| aws | ~> 2.7 |
| local | ~> 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_ca | The CA cert for client authentication. Only necessary if write\_ovpn\_config is set to true. | `string` | `""` | no |
| client\_certificate\_name | The name of the client certificate in AWS ACM. | `string` | n/a | yes |
| client\_cidr | The address space to use for VPN clients. | `string` | n/a | yes |
| name | The name of this VPN. | `string` | n/a | yes |
| security\_group\_name | The security group name to access the VPN server. | `string` | n/a | yes |
| server\_certificate\_name | The name of the server certificate in AWS ACM. | `string` | n/a | yes |
| subnet\_ids | The ids of the subnets to associate with this VPN. | `list(string)` | n/a | yes |
| transport\_protocol | The transport protocol. (UDP or TCP). | `string` | n/a | yes |
| write\_ovpn\_config | Write an openVPN config file. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_cidr | The address space of VPN clients. |
| dns\_name | The dns name of the VPN server. |
| routes | A list of route information in the form {network, netmask}. |
