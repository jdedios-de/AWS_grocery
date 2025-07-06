cidr_block = "10.0.0.0/16"

environment  = "dev"
subnet_count = 2
azs = [
  "eu-central-1a",
  "eu-central-1b",
]
tags = {
  Project     = "grocery-app"
  Environment = "dev"
}


# Database
db_name        = "grocerymate_db"
username       = "grocery_user"
password       = "grocery_test"
engine         = "postgres"
eng_version    = "14.17"
alloc_storage  = 10
instance_class = "db.t3.micro"
storage_type   = "gp2"

# ALB
health_check_path     = "/health"
health_check_matcher  = "200-399"
health_check_interval = 30
target_port           = 5000


# EC2
instance_type  = "t2.micro"
instance_name  = "grocery-app"
cluster_name   = "grocery-app-ecs-cluster"
container_name = "grocerymate"
key_name       = "jerome-aws-frankfurt"
min_size       = 2
max_size       = 3
desired_count  = 2

