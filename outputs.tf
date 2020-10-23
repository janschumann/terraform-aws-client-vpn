output "dns_name" {
  description = "The dns name of the VPN server."
  value       = replace(aws_ec2_client_vpn_endpoint.this.dns_name, "*.", "")
}

output "client_cidr" {
  description = "The address space of VPN clients."
  value       = aws_ec2_client_vpn_endpoint.this.client_cidr_block
}

output "routes" {
  description = "A list of route information in the form {network, netmask}."
  value = [
    for r in aws_ec2_client_vpn_network_association.this : {
      network = data.aws_subnet.this[r.subnet_id].cidr_block
      netmask = cidrnetmask(data.aws_subnet.this[r.subnet_id].cidr_block)
    }
  ]
}
