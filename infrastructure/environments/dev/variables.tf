variable "region" {
  description = "region"
  type        = string
  default     = "eu-central-1"
}

variable "azs" {
  description = "availability zones"
  type        = list(string)
}

variable "environment" {
  description = "environment of vpc"
  type        = string
}

variable "tags" {
  description = "environment of vpc"
  type        = map(string)
}

variable "subnet_count" {
  description = "subnet count"
  type        = number
}

variable "target_port" {
  description = "subnet count"
  type        = number
}

variable "cidr_block" {
  description = "cidr block"
  type        = string
}

variable "storage_type" { type = string }
variable "alloc_storage" { type = number }
variable "engine" { type = string }
variable "eng_version" { type = string }
variable "instance_class" { type = string }
variable "db_name" { type = string }
variable "username" { type = string }
variable "password" { type = string }

variable "health_check_path" { type = string }
variable "health_check_matcher" { type = string }
variable "health_check_interval" { type = number }

variable "health_check_healthy_threshold" { type = number }
variable "health_check_unhealthy_threshold" { type = number }
variable "health_check_timeout" { type = number }

variable "cluster_name" { type = string }
variable "instance_type" { type = string }
variable "instance_name" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_count" { type = number }
variable "container_name" { type = string }
variable "key_name" { type = string }

variable "bucket_name" { type = string }
variable "folder_name" { type = string }

variable "docker_image" {
  default = "995757496625.dkr.ecr.eu-central-1.amazonaws.com/grocerymate:latest"
}

