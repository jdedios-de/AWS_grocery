resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix        = "ecs-asg-${var.environment}"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_count
  vpc_zone_identifier = var.public_subnets

  tag {
    key                 = "Name"
    value               = "${var.environment}-aws-ecs-asg"
    propagate_at_launch = true
  }
}

