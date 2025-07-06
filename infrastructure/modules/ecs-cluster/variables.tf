variable "cluster_name" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_count" { type = number }
variable "environment" { type = string }