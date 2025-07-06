resource "aws_lb_listener" "http" {
  load_balancer_arn = var.alb_arn
  port              = var.target_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
