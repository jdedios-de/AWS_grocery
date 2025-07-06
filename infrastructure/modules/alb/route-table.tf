resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-rt"
  })
}

resource "aws_route_table_association" "this" {
  count        = var.subnet_count
  subnet_id      = var.public_subnets[count.index]
  route_table_id = aws_route_table.this.id
}