variable "vpc_id" { type = string }
variable "cluster_name" { type = string }
variable "instance_name" { type = string }
variable "instance_type" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_count" { type = number }
variable "environment" { type = string }
variable "tags" { type = map(string)}
variable "target_port" { type = number }

variable "public_subnets" { type        = list(string) }

variable "alb_ec2_security_group" { type        = string }

variable "instance_profile_name" { type = string }

variable "ecs_task_execution_role" { type = string }

variable "db_endpoint" { type = string }

variable "alb_arn" { type = string }

variable "target_group_arn" { type = string }

variable "docker_image" { type = string }

variable "container_name" { type = string }

variable "key_name" { type = string }

variable "db_name" { type = string }

variable "username" { type = string }

variable "password" { type = string }