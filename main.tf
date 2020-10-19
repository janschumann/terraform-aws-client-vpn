resource "aws_ec2_client_vpn_endpoint" "this" {
  client_cidr_block      = var.client_cidr
  split_tunnel           = true
  server_certificate_arn = data.aws_acm_certificate.server.arn

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client.arn
  }

  connection_log_options {
    enabled = false
  }

  transport_protocol = "tcp"

  tags = {
    Name = var.name
  }
}

/** TODO: deactivated currently because of https://github.com/terraform-providers/terraform-provider-aws/issues/15680
          unfortunately this resource cannot be imported either

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = data.aws_subnet.this
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value.id
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  for_each               = data.aws_subnet.this
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value.cidr_block
  authorize_all_groups   = true
}

**/

resource "local_file" "config" {
  count = var.create_client_config ? 1 : 0

  filename = format("%s.ovpn", var.name)

  content = templatefile(format("%s/client_config.tpl", path.module), {
    endpoint = aws_ec2_client_vpn_endpoint.this.dns_name
    routes = join("\n", formatlist("route %s", [
      for s in data.aws_subnet.this : format("%s %s", s.cidr_block, cidrnetmask(s.cidr_block))
    ]))
  })
}


