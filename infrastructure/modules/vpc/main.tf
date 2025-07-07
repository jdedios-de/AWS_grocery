resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names

  subnet_cidrs = [
    for idx in range(var.subnet_count * 2) :
    cidrsubnet(var.cidr_block, 8, idx)
  ]

  public_cidrs  = slice(local.subnet_cidrs, 0, var.subnet_count)
  private_cidrs = slice(local.subnet_cidrs, var.subnet_count, var.subnet_count * 2)
}