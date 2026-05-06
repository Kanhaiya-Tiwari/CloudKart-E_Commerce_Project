# Project: CloudKart
# File: vpc.tf
# Description: Terraform infrastructure as code file.
# How to use: Managed using terraform commands.
# Why it exists: To automate AWS resource provisioning.
# When it's used: During infrastructure deployment/updates.

module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name            = local.name
  cidr            = local.vpc_cidr
  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  # Ensure public subnets auto-assign public IPs
  map_public_ip_on_launch = true

}