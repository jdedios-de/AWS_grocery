terraform {
}

provider "aws" {
  region = var.region
}


# VPC
module "vpc" {
  source       = "../../modules/vpc"
  cidr_block   = "10.0.0.0/16"
  environment  = var.environment
  subnet_count = var.subnet_count
  azs          = var.azs
  tags         = var.tags
}

# ALB
module "alb" {
  source                = "../../modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  target_port           = var.target_port
  environment           = var.environment
  health_check_path     = var.health_check_path
  health_check_matcher  = var.health_check_matcher
  health_check_interval = var.health_check_interval
  tags                  = var.tags
  subnet_count          = var.subnet_count
}







