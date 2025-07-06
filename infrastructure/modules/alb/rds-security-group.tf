# Database Security Group
resource "aws_security_group" "rds_sg" {
  name     = "${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id = var.vpc_id

  ingress { 
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = [aws_security_group.ec2_sg.id]
  }
  egress  { 
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-rds-sg"
  })
}
