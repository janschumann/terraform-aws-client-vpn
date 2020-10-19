data "aws_acm_certificate" "server" {
  domain   = var.server_certificate_name
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "client" {
  domain   = var.client_certificate_name
  statuses = ["ISSUED"]
}

data "aws_security_group" "this" {
  name = var.security_group_name
}

data "aws_subnet" "this" {
  for_each = toset(var.subnets)
  vpc_id   = var.vpc_id
  id       = each.value
}
