terraform {
}

provider "aws" {
  region = var.region
}


# VPC
module "vpc" {
  source       = "../../modules/vpc"
  cidr_block   = var.cidr_block
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

  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_timeout             = var.health_check_timeout


  subnet_count = var.subnet_count
  tags         = var.tags
}

module "global" {
  source = "../../global"
  region = var.region
}

# ECS Cluster + ASG
module "ecs_cluster" {
  source         = "../../modules/ecs-cluster"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  instance_type  = var.instance_type
  environment    = var.environment
  min_size       = var.min_size
  max_size       = var.max_size
  desired_count  = var.desired_count
  cluster_name   = var.cluster_name
  instance_name  = var.instance_name
  docker_image   = var.docker_image
  container_name = var.container_name
  key_name       = var.key_name
  tags           = var.tags
  target_port    = var.target_port
  db_name        = var.db_name
  username       = var.username
  password       = var.password

  alb_ec2_security_group  = module.alb.alb_ec2_security_group
  alb_arn                 = module.alb.alb_arn
  target_group_arn        = module.alb.target_group_arn
  instance_profile_name   = module.global.ecs_instance_profile_name
  ecs_task_execution_role = module.global.ecs_task_execution_role
  db_endpoint             = module.rds.db_endpoint
}

# RDS
module "rds" {
  source                 = "../../modules/rds"
  vpc_security_group_ids = [module.alb.alb_rds_security_group]
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  environment            = var.environment
  eng_version            = var.eng_version
  instance_class         = var.instance_class
  storage_type           = var.storage_type
  alloc_storage          = var.alloc_storage
  engine                 = var.engine
  private_subnets        = module.vpc.private_subnets
}






