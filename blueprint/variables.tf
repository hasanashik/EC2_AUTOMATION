variable "vpc_ipv4_primary_cidr_block" {
  default = null
  type    = string
}
variable "vpc_instance_tenancy" {
  default = "default"
  type    = string
}
variable "vpc_private_subnet_cidr" {
  default = null
  type    = string
}
