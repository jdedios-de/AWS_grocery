# Private subnets
resource "aws_subnet" "private" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_cidrs[count.index]
  availability_zone       = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-private-${count.index}"
      Environment = var.environment
    }
  )
}
