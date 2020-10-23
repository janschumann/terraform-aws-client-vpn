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

  transport_protocol = lower(var.transport_protocol)

  tags = {
    Name = var.name
  }
}

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

resource "local_file" "config" {
  count = var.write_ovpn_config && var.client_ca != "" ? 1 : 0

  filename = format("%s.ovpn", var.name)

  content = templatefile(format("%s/config.ovpn.tpl", path.module), {
    endpoint = replace(aws_ec2_client_vpn_endpoint.this.dns_name, "*.", "")
    routes = join("\n", formatlist("route %s", [
      for s in data.aws_subnet.this : format("%s %s", s.cidr_block, cidrnetmask(s.cidr_block))
    ]))
    client_cert_arn = aws_ec2_client_vpn_endpoint.this.authentication_options[0].root_certificate_chain_arn
    ca_cert         = var.client_ca
  })
}


