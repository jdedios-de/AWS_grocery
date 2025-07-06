resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(var.tags, {
    Name = "${var.environment}-public-${count.index}"
  })
}

resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.10${count.index}.0/24"
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-${count.index}"
  })
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(var.tags, {
    Name = "${var.environment}-db-subnet-group"
  })
}