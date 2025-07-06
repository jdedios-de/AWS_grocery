resource "aws_security_group" "alb_sg" {
  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id

  ingress { 
      from_port = 80
      to_port = 80  
      protocol = "tcp"  
      cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress { 
    from_port = var.target_port
    to_port = var.target_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress { 
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


  egress  { 
    from_port = 0
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-security-group"
  })
}