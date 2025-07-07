resource "aws_ecs_service" "this" {
  name            = "ecs-service-${var.container_name}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.target_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  depends_on = [
    aws_lb_listener.http
  ]
}