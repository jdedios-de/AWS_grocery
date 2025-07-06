variable "azs" { type = list(string) }
variable "environment" { type = string }
variable "tags" { type = map(string) }
variable "subnet_count" { type = number }
variable "cidr_block" { type = string }