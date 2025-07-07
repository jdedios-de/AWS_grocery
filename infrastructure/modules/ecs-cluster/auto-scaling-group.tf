resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix        = "ecs-asg-${var.environment}"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = aws_launch_template.ecs.latest_version
  }
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_count
  vpc_zone_identifier = var.public_subnets

  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.environment}-aws-ecs-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

