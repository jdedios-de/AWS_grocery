resource "aws_ecs_task_definition" "this" {
  family                   = "grocerymate-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.docker_image
      essential = true
      portMappings = [
        {
          containerPort = var.target_port
          hostPort      = var.target_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_USER"
          value = var.username
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = var.password
        },
        {
          name  = "POSTGRES_DB"
          value = var.db_name
        },
        {
          name  = "POSTGRES_HOST"
          value = var.db_endpoint
        },
        {
          name  = "POSTGRES_URI"
          value = "postgresql://${var.username}:${var.password}@${var.db_endpoint}:5432/${var.db_name}"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = var.bucket_name
        },
        {
          name  = "S3_REGION"
          value = "eu-central-1"
        },
        {
          name  = "USE_S3_STORAGE"
          value = "true"
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