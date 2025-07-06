resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name}"
}

data "aws_ssm_parameter" "this" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-instance-"
  image_id      = data.aws_ssm_parameter.this.value
  instance_type = var.instance_type
  key_name      = "jerome-aws-frankfurt"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name     = var.instance_name
      ExtraTag = local.extra_tag
    }
  }
}

resource "aws_ecs_task_definition" "grocerymate" {
  family                   = "grocerymate-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "grocerymate"
      image     = var.docker_image
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_USER"
          value = "grocery_user"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = "grocery_test"
        },
        {
          name  = "POSTGRES_DB"
          value = "grocerymate_db"
        },
        {
          name  = "POSTGRES_HOST"
          value = aws_db_instance.db_instance.address
        },
        {
          name  = "POSTGRES_URI"
          value = "postgresql://grocery_user:grocery_test@${aws_db_instance.db_instance.address}:5432/grocerymate_db"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/grocerymate"
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grocerymate" {
  name            = "grocerymate-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grocerymate.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "grocerymate"
    container_port   = 5000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.grocery_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix        = "ecs-asg-${var.environment}-"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_count
  vpc_zone_identifier = var.public_subnets
  tags = [
    { key = "Name", value = var.environment, propagate_at_launch = true }
  ]
}
