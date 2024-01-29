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

# resource "aws_vpc" "zaman_vpc" {
#   cidr_block = "10.10.0.0/16"
#   tags = {
#     Name = "zaman_vpc_dev"
#   }
# }
# resource "aws_internet_gateway" "zaman_vpc_igw" {
#   tags = {
#     Name = "zaman_vpc_dev_igw"
#   }
# }
# resource "aws_internet_gateway_attachment" "vpc_igw" {
#   vpc_id              = resource.aws_vpc.zaman_vpc.id
#   internet_gateway_id = resource.aws_internet_gateway.zaman_vpc_igw.id

# }
# resource "aws_subnet" "eks_cluster" {
#   vpc_id     = resource.aws_vpc.zaman_vpc.id
#   cidr_block = "10.10.1.0/24"

#   tags = {
#     Name = "eks_cluster"
#   }
# }
# resource "aws_subnet" "db_subnet" {
#   vpc_id     = resource.aws_vpc.zaman_vpc.id
#   cidr_block = "10.10.2.0/24"
#   tags = {
#     Name = "eks_cluster_db"
#   }
# }



