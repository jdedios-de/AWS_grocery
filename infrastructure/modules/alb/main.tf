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

resource "aws_lb" "this" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-lb"
  })
}

resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = var.health_check_path
    matcher  = var.health_check_matcher
    interval = var.health_check_interval
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-lb-target-group"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.target_port
  protocol          = "HTTP"
  default_action { 
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-lb-listener"
  })
}

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

# EC2 Security Group

resource "aws_security_group" "ec2_sg" {
  name     = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id = var.vpc_id

  ingress { 
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { 
    from_port = 5000
    to_port = 5000
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
    Name = "${var.environment}-aws-ec2-sg"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-ig"
  })
}

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

