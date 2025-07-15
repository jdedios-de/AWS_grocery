variable "storage_type" { type = string }
variable "alloc_storage" { type = number }
variable "engine" { type = string }
variable "eng_version" { type = string }
variable "instance_class" { type = string }
variable "db_name" { type = string }
variable "username" { type = string }
variable "password" { type = string }
variable "environment" { type = string }


variable "vpc_security_group_ids" {
  type        = list(string)
}

variable "private_subnets" {
  description = "List of public subnet IDs to associate with the ALB"
  type        = list(string)
}

variable "tags" { type = map(string) }