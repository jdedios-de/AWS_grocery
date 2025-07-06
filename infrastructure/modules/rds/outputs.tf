output "db_endpoint" { value = aws_db_instance.this.address }
output "db_subnet_group" { value = aws_db_subnet_group.this.name }