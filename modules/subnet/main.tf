# Section: Local Variables
locals {
  # General flag to enable or disable subnet creation
  enabled = module.this.enabled && (var.public_subnets_enabled || var.private_subnets_enabled) && (var.ipv4_enabled || var.ipv6_enabled)

  # Abbreviation for `enabled`
  e               = local.enabled
  private_enabled = local.e && var.private_subnets_enabled

  # Map of availability zone IDs
  az_id_map = try(zipmap(data.aws_availability_zones.default[0].zone_ids, data.aws_availability_zones.default[0].names), {})

  # Map of options for availability zones
  az_option_map = {
    from_az_ids = local.e ? [for id in var.availability_zone_ids : local.az_id_map[id]] : []
    from_az_var = local.e ? var.availability_zones : []
    all_azs     = local.e ? sort(data.aws_availability_zones.default[0].names) : []
  }

  # Use availability zone IDs or names based on user input
  use_az_ids = local.e && length(var.availability_zone_ids) > 0
  use_az_var = local.e && length(var.availability_zones) > 0
  subnet_availability_zone_option = local.use_az_ids ? "from_az_ids" : (
    local.use_az_var ? "from_az_var" : "all_azs"
  )
  subnet_possible_availability_zones = local.az_option_map[local.subnet_availability_zone_option]
  vpc_availability_zones = (
    var.max_subnet_count == 0 || var.max_subnet_count >= length(local.subnet_possible_availability_zones)
    ) ? (
    local.subnet_possible_availability_zones
  ) : slice(local.subnet_possible_availability_zones, 0, var.max_subnet_count)

  subnet_availability_zones = flatten([for z in local.vpc_availability_zones : [for net in range(0, var.subnets_per_az_count) : z]])

  subnet_az_count = local.e ? length(local.subnet_availability_zones) : 0

  # VPC and IP version flags
  vpc_id           = var.vpc_id
  ipv4_enabled     = local.e && var.ipv4_enabled
  ipv6_enabled     = local.e && var.ipv6_enabled
  private4_enabled = local.private_enabled && local.ipv4_enabled
  private6_enabled = local.private_enabled && local.ipv6_enabled

  # CIDR calculations and reservations
  existing_az_count         = local.e ? length(data.aws_availability_zones.default[0].names) : 0
  base_cidr_reservations    = (var.max_subnet_count == 0 ? local.existing_az_count : var.max_subnet_count) * var.subnets_per_az_count
  private_cidr_reservations = (local.private_enabled ? 1 : 0) * local.base_cidr_reservations
  public_enabled            = local.e && var.public_subnets_enabled
  public_cidr_reservations  = (local.public_enabled ? 1 : 0) * local.base_cidr_reservations
  cidr_reservations         = local.private_cidr_reservations + local.public_cidr_reservations

  # IPv6 CIDR related calculations
  supplied_ipv6_private_subnet_cidrs = try(var.ipv6_cidrs[0].private, [])
  supplied_ipv6_public_subnet_cidrs  = try(var.ipv6_cidrs[0].public, [])
  compute_ipv6_cidrs                 = local.ipv6_enabled && (length(local.supplied_ipv6_private_subnet_cidrs) + length(local.supplied_ipv6_public_subnet_cidrs)) == 0
  need_vpc_data                      = (local.compute_ipv4_cidrs && length(var.ipv4_cidr_block) == 0) || (local.compute_ipv6_cidrs && length(var.ipv6_cidr_block) == 0)

  # Base CIDR block for IPv4
  base_ipv4_cidr_block = length(var.ipv4_cidr_block) > 0 ? var.ipv4_cidr_block[0] : (local.need_vpc_data ? data.aws_vpc.default[0].cidr_block : "")

  # IPv4 CIDR calculations and reservations
  compute_ipv4_cidrs                 = local.ipv4_enabled && (length(local.supplied_ipv4_private_subnet_cidrs) + length(local.supplied_ipv4_public_subnet_cidrs)) == 0
  supplied_ipv4_private_subnet_cidrs = try(var.ipv4_cidrs[0].private, [])
  supplied_ipv4_public_subnet_cidrs  = try(var.ipv4_cidrs[0].public, [])

  # Calculate required IPv4 subnet bits
  required_ipv4_subnet_bits = local.e ? ceil(log(local.cidr_reservations, 2)) : 1

  # Private IPv4 subnets
  ipv4_private_subnet_cidrs = local.compute_ipv4_cidrs ? [
    for net in range(0, local.private_cidr_reservations) : cidrsubnet(local.base_ipv4_cidr_block, local.required_ipv4_subnet_bits, net)
  ] : local.supplied_ipv4_private_subnet_cidrs

  # Required IPv6 subnet bits and base CIDR block
  required_ipv6_subnet_bits = 8 # Currently the only value allowed by AWS
  base_ipv6_cidr_block      = length(var.ipv6_cidr_block) > 0 ? var.ipv6_cidr_block[0] : (local.need_vpc_data ? data.aws_vpc.default[0].ipv6_cidr_block : "")

  # Private IPv6 subnets
  ipv6_private_subnet_cidrs = local.compute_ipv6_cidrs ? [
    for net in range(0, local.private_cidr_reservations) : cidrsubnet(local.base_ipv6_cidr_block, local.required_ipv6_subnet_bits, net)
  ] : local.supplied_ipv6_private_subnet_cidrs

  # Public IPv6 subnets
  ipv6_public_subnet_cidrs = local.compute_ipv6_cidrs ? [
    for net in range(local.private_cidr_reservations, local.cidr_reservations) : cidrsubnet(local.base_ipv6_cidr_block, local.required_ipv6_subnet_bits, net)
  ] : local.supplied_ipv6_public_subnet_cidrs

  # Availability Zone abbreviation mapping
  az_abbreviation_map_map = {
    short = "to_short"
    fixed = "to_fixed"
    full  = "identity"
  }

  # Map of AZ abbreviations
  az_abbreviation_map = module.utils.region_az_alt_code_maps[local.az_abbreviation_map_map[var.availability_zone_attribute_style]]

  # Delimiter for AZ-based Names/IDs
  delimiter               = module.this.delimiter
  subnet_az_abbreviations = [for az in local.subnet_availability_zones : local.az_abbreviation_map[az]]
  public4_enabled         = local.public_enabled && local.ipv4_enabled

  # Default for private_dns64_enabled
  private_dns64_enabled = local.private6_enabled && (
    var.private_dns64_nat64_enabled == null ? local.public4_enabled : var.private_dns64_nat64_enabled
  )
}

# Section: Resource Block for AWS Subnet - Private
resource "aws_subnet" "private" {
  count = local.private_enabled ? local.subnet_az_count : 0

  vpc_id            = local.vpc_id
  availability_zone = local.subnet_availability_zones[count.index]

  # IPv4 CIDR block for private subnets
  cidr_block = local.private4_enabled ? local.ipv4_private_subnet_cidrs[count.index] : null
  # IPv6 CIDR block for private subnets
  ipv6_cidr_block = local.private6_enabled ? local.ipv6_private_subnet_cidrs[count.index] : null
  # Flag to indicate native IPv6
  ipv6_native = local.private6_enabled && !local.private4_enabled

  # Tags for the subnet
  tags = merge(
    module.private_label.tags,
    {
      "Name" = format("%s%s%s", module.private_label.id, local.delimiter, local.subnet_az_abbreviations[count.index])
    }
  )

  # IPv6 and DNS related settings
  assign_ipv6_address_on_creation = local.private6_enabled ? var.private_assign_ipv6_address_on_creation : null
  enable_dns64                    = local.private6_enabled ? local.private_dns64_enabled : null

  # Resource name DNS A record on launch
  enable_resource_name_dns_a_record_on_launch = local.private4_enabled ? var.ipv4_private_instance_hostnames_enabled : null
  # Resource name DNS AAAA record on launch for IPv6
  enable_resource_name_dns_aaaa_record_on_launch = local.private6_enabled ? var.ipv6_private_instance_hostnames_enabled || !local.private4_enabled : null

  # Private DNS hostname type on launch
  private_dns_hostname_type_on_launch = local.private4_enabled ? var.ipv4_private_instance_hostname_type : null

  # Ignore certain changes during lifecycle
  lifecycle {
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }

  # Timeouts for subnet creation and deletion
  timeouts {
    create = var.subnet_create_timeout
    delete = var.subnet_delete_timeout
  }
}
