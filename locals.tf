locals {
  /**
   *  Validate VPC (security group and subnet VPCs must match)
   */
  vpc_id_from_security_group = data.aws_security_group.this.vpc_id
  vpc_ids_from_subnets = distinct([
    for subnet in data.aws_subnet.this : subnet.vpc_id
  ])
  vpc_id = length(local.vpc_ids_from_subnets) == 1 && local.vpc_ids_from_subnets[0] == local.vpc_id_from_security_group ? local.vpc_id_from_security_group : ""

  /**
   *  Validate subnets (for each availablility zone, only one subnet can be associated)
   */
  zones = {
    for subnet in data.aws_subnet.this : subnet.availability_zone => subnet.id...
  }
  subnet_count = {
    for zone, subnets in local.zones : zone => length(subnets)
  }
  zones_valid = length(keys(local.zones)) / sum(values(local.subnet_count)) >= 1

  /*
   * Prepare error messages
   */
  errors = compact(concat(
    length(local.vpc_ids_from_subnets) != 1 ? format("All subnets must be from within the same VPC. Found %s.", join(", ", local.vpc_ids_from_subnets)) : [],
    local.vpc_id != local.vpc_id_from_security_group ? format("Subnets and Security group VPC must be the same. Security group VPC is %s.", local.vpc_id_from_security_group) : [],
    ! local.zones_valid ? format("Only one subnet per availability zone is allowed. Availability zones with more that one subnet: %s.", join(", ", [for zone, subnet_count in local.subnet_count : zone if subnet_count > 1])) : [],
  ))
}
