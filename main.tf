terraform {
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  extra_tag = "extra-tag"
}

resource "aws_vpc" "grocery_app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "grocery-app-vpc"
  }
}

resource "aws_subnet" "public_grocery_app_subnet_a" {
  count             = 2
  vpc_id            = aws_vpc.grocery_app_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(["eu-central-1a", "eu-central-1b"], count.index)
  
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_grocery_app_subnet_a" {
  vpc_id            = aws_vpc.grocery_app_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "private-grocery-app-subnet-a"
  }
}


resource "aws_subnet" "private_grocery_app_subnet_b" {
  vpc_id            = aws_vpc.grocery_app_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "private-grocery-app-subnet-b"
  }
}

resource "aws_db_subnet_group" "grocery_subnet_group" {
  name       = "grocery_subnet_group"
  subnet_ids = [aws_subnet.private_grocery_app_subnet_a.id, aws_subnet.private_grocery_app_subnet_b.id]
  tags = {
    Name = "grocery app subnet group"
  }
}

resource "aws_internet_gateway" "grocery_app_igw" {
  vpc_id = aws_vpc.grocery_app_vpc.id
  tags = {
    Name = "grocery-app-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.grocery_app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grocery_app_igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count        = 2
  subnet_id      = aws_subnet.public_grocery_app_subnet_a[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}







resource "aws_security_group" "ec2_sg" {
  name        = "grocery-app-ec2-sg"
  description = "Security group for grocery app EC2 instance"
  vpc_id      = aws_vpc.grocery_app_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom port for grocery applications"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "grocery-app-ec2-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "grocery-app-rds-sg"
  description = "Security group for grocery app RDS instance"
  vpc_id      = aws_vpc.grocery_app_vpc.id

  ingress {
    description     = "Allow PostgreSQL from EC2 security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grocery-app-rds-sg"
  }
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_instance" {
  name_prefix   = "ecs-instance-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
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
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
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

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = aws_subnet.public_grocery_app_subnet_a[*].id
  desired_capacity    = 2
  min_size            = 2
  max_size            = 3

  launch_template {
    id      = aws_launch_template.ecs_instance.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "ECS_CLUSTER"
    value               = aws_ecs_cluster.main.name
    propagate_at_launch = true
  }
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

  # Make sure your service has a deployment minimum healthy percent
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http
  ]
}


resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "14.17"
  instance_class      = "db.t3.micro"
  db_name             = "grocerymate_db"
  username            = var.db_user
  password            = var.db_pass
  db_subnet_group_name   = aws_db_subnet_group.grocery_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
}


resource "aws_ecs_cluster" "main" {
  name = "grocerymate-ecs-cluster"
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

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

#
# 1) ALB Security Group
#
resource "aws_security_group" "alb_sg" {
  name        = "grocery-app-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.grocery_app_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grocery-app-alb-sg"
  }
}

#
# 2) Application Load Balancer
#
resource "aws_lb" "grocery_alb" {
  name               = "grocerymate-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_grocery_app_subnet_a[*].id

  tags = {
    Name = "grocerymate-alb"
  }
}

#
# 3) Target Group
#
resource "aws_lb_target_group" "ecs_tg" {
  name     = "grocerymate-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.grocery_app_vpc.id

  health_check {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name = "grocerymate-tg"
  }
}

#
# 4) Listener (HTTP → TG)
#
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.grocery_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}




