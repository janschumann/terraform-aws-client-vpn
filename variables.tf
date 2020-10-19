variable "name" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
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

variable "create_client_config" {
  type    = bool
  default = false
}
