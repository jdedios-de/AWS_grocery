resource "aws_ecs_task_definition" "this" {
  family                   = "grocerymate-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "ecs-task-definition-${var.container_name}"
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
          value = var.db_endpoint
        },
        {
          name  = "POSTGRES_URI"
          value = "postgresql://grocery_user:grocery_test@${var.db_endpoint}:5432/grocerymate_db"
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