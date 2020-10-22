variable "name" {
  description = "The name of this VPN."
  type        = string

  validation {
    condition     = var.name != ""
    error_message = "Name must not be empty."
  }
}

variable "security_group_name" {
  description = "The security group name to access the VPN server."
  type        = string

  validation {
    condition     = var.security_group_name != ""
    error_message = "Security group must not be empty."
  }
}

variable "subnet_ids" {
  description = "The ids of the subnets to associate with this VPN."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "Please provide at least one subnet id."
  }
}

variable "transport_protocol" {
  description = "The transport protocol. (UDP or TCP)."
  type        = string

  validation {
    condition     = contains(["udp", "tcp"], lower(var.transport_protocol))
    error_message = "Transport Protocol can only be TCP or UDP."
  }
}

variable "server_certificate_name" {
  description = "The name of the server certificate in AWS ACM."
  type        = string

  validation {
    condition     = var.server_certificate_name != ""
    error_message = "Server certificate name must not be empty."
  }
}

variable "client_certificate_name" {
  description = "The name of the client certificate in AWS ACM."
  type        = string

  validation {
    condition     = var.client_certificate_name != ""
    error_message = "Client certificate name must not be empty."
  }
}

variable "client_cidr" {
  description = "The address space to use for VPN clients."
  type        = string

  validation {
    condition     = length(split("/", var.client_cidr)) == 2 && split("/", var.client_cidr)[1] <= 22
    error_message = "The client address space must be cidr notation and must be at least a /22 network."
  }
}

variable "write_ovpn_config" {
  description = "Write an openVPN config file."
  type        = bool
  default     = false
}

variable "client_ca" {
  description = "The CA cert for client authentication. Only necessary if write_ovpn_config is set to true."
  type        = string
  default     = ""
}
