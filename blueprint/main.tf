module "vpc" {
  source                  = "./modules/vpc"
  ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block
  instance_tenancy        = var.vpc_instance_tenancy
}

module "private_subnet" {
  source       = "./modules/subnet"
  vpc_id       = module.vpc.vpc_id
  private_cidr = var.vpc_private_subnet_cidr
}
module "ec2" {
  source = "./modules/ec2"
}
