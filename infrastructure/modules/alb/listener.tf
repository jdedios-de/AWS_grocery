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