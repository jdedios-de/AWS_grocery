resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name}"
}

data "aws_ssm_parameter" "this" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}




