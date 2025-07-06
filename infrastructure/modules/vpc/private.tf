resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.10${count.index}.0/24"
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-${count.index}"
  })
}