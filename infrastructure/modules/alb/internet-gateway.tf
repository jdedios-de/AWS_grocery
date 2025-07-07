resource "aws_internet_gateway" "public" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    { 
      Name = "${var.environment}-igw"
      Environment = var.environment
    }
  )
}