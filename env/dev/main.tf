terraform {
  cloud {
    organization = "zaman-iac"

    workspaces {
      name = "ec2_automation"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "dev_infra" {
  source                      = "../../blueprint"
  vpc_ipv4_primary_cidr_block = "10.10.0.0/16"
  vpc_instance_tenancy        = "default"
  vpc_private_subnet_cidr     = "10.10.2.0/24"
}
