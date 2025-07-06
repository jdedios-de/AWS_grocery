output "alb_arn" { value = aws_lb.this.arn }

output "alb_dns_name" { value = aws_lb.this.dns_name }

output "target_group_arn" { value = aws_lb_target_group.this.arn }

output "alb_ec2_security_group" { value = aws_security_group.ec2_sg.id }

output "alb_rds_security_group" { value = aws_security_group.rds_sg.id }
