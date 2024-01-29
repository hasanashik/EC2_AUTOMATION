locals {
  enabled                  = module.this.enabled
  ipv4_primary_cidr_block  = var.ipv4_primary_cidr_block
  internet_gateway_enabled = local.enabled && var.internet_gateway_enabled
}
resource "aws_vpc" "main" {
  cidr_block       = local.ipv4_primary_cidr_block
  instance_tenancy = var.instance_tenancy
  tags = {
    Name = "main"
  }
}
resource "aws_internet_gateway" "default" {
  count = local.internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id
  tags   = module.label.tags
}
