resource "aws_lb" "this" {
  name                 = "${var.environment}-alb"
  internal             = false
  load_balancer_type   = "application"
  security_groups      = [aws_security_group.alb_sg.id]
  subnets              = var.public_subnets

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-alb"
      Environment = var.environment
    }
  )
}

resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval

    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-ecs-tg"
      Environment = var.environment
    }
  )
}