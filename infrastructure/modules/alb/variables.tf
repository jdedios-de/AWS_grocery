variable "vpc_id" { type = string }
variable "target_port" { type = number }
variable "health_check_path" { type = string}
variable "health_check_matcher" { type = string}
variable "health_check_interval" { type = number}

variable "health_check_healthy_threshold" { type = number}
variable "health_check_unhealthy_threshold" { type = number}
variable "health_check_timeout" { type = number}

variable "environment" { type = string }
variable "tags" { type = map(string)}

variable "subnet_count" {
  description = "subnet count"
  type        = number
}

variable "public_subnets" {
  description = "List of public subnet IDs to associate with the ALB"
  type        = list(string)
}

variable "admin_cidr" {
  type        = string
  description = "The CIDR range for admin SSH access"
  default     = "80.141.136.240/32"
}