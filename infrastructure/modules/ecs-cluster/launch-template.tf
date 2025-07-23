resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-instance-"
  image_id      = data.aws_ssm_parameter.this.value
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.alb_ec2_security_group]
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
    Name = "${var.environment}-aws-launch-template-ecs"
    })
  }
}
