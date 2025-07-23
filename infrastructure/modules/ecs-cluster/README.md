# ECS Cluster Module

This Terraform module creates an **AWS ECS (Elastic Container Service) cluster** with an Auto Scaling Group (ASG), launch template, task definition, service, and an HTTP load balancer listener. It is designed to deploy a containerized **grocery application** with auto-scaling, load balancing, and integration with **RDS** and **S3** services.

---

## 📥 Inputs

| Name                    | Type           | Description                                                                  |
|-------------------------|----------------|------------------------------------------------------------------------------|
| `vpc_id`                | `string`       | The ID of the VPC to deploy the cluster in.                                  |
| `cluster_name`          | `string`       | The name of the ECS cluster (e.g., `"grocery-app-ecs-cluster"`).             |
| `instance_name`         | `string`       | The name for EC2 instances in the ASG.                                       |
| `instance_type`         | `string`       | The EC2 instance type (e.g., `"t2.micro"`).                                  |
| `min_size`              | `number`       | The minimum number of instances in the ASG.                                  |
| `max_size`              | `number`       | The maximum number of instances in the ASG.                                  |
| `desired_count`         | `number`       | The desired number of tasks running in the service.                          |
| `environment`           | `string`       | The environment name (e.g., `"dev"`, `"prod"`).                              |
| `tags`                  | `map(string)`  | Additional tags to apply to resources.                                       |
| `target_port`           | `number`       | The port for the container and load balancer (e.g., `5000`).                 |
| `public_subnets`        | `list(string)` | List of public subnet IDs for the ASG.                                       |
| `alb_ec2_security_group`| `string`       | The security group ID for ALB and EC2 instances.                             |
| `instance_profile_name` | `string`       | The IAM instance profile name for EC2 instances.                             |
| `ecs_task_execution_role` | `string`     | The ARN of the IAM role for task execution.                                  |
| `db_endpoint`           | `string`       | The endpoint of the RDS database.                                            |
| `alb_arn`               | `string`       | The ARN of the Application Load Balancer.                                    |
| `target_group_arn`      | `string`       | The ARN of the target group for the load balancer.                           |
| `docker_image`          | `string`       | The Docker image to run in the ECS task.                                     |
| `container_name`        | `string`       | The name of the container (e.g., `"grocerymate"`).                           |
| `key_name`              | `string`       | The SSH key pair name for EC2 instances.                                     |
| `db_name`               | `string`       | The name of the database.                                                    |
| `username`              | `string`       | The database username.                                                       |
| `password`              | `string`       | The database password.                                                       |
| `bucket_name`           | `string`       | The name of the S3 bucket for storage.                                       |

---

## 📤 Outputs

| Name       | Description                                 |
|------------|---------------------------------------------|
| `cluster_id` | The ID of the created ECS cluster.         |
| `asg_name`   | The name of the Auto Scaling Group.        |

---

## 🚀 Usage Example

```hcl
module "ecs_cluster" {
  source                 = "./modules/ecs-cluster"
  vpc_id                 = module.vpc.vpc_id
  cluster_name           = "grocery-app-ecs-cluster"
  instance_name          = "grocery-app"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 3
  desired_count          = 2
  environment            = "dev"
  tags                   = { Project = "grocery-app" }
  target_port            = 5000
  public_subnets         = module.vpc.public_subnets
  alb_ec2_security_group = module.alb.alb_ec2_security_group
  instance_profile_name  = module.global.ecs_instance_profile_name
  ecs_task_execution_role = module.global.ecs_task_execution_role
  db_endpoint            = module.rds.db_endpoint
  alb_arn                = module.alb.alb_arn
  target_group_arn       = module.alb.target_group_arn
  docker_image           = "myregistry/grocerymate:latest"
  container_name         = "grocerymate"
  key_name               = "jerome-aws-frankfurt"
  db_name                = "grocerymate_db"
  username               = "grocery_user"
  password               = "grocery_test"
  bucket_name            = "j-grocerymate-avatars"
}
```

---

## 🧱 Resources Created

### 🔹 ECS Cluster

- **Resource**: `aws_ecs_cluster.this`
- **Description**: Creates a cluster named `${environment}-${cluster_name}` (e.g., `dev-grocery-app-ecs-cluster`).

### 🔹 Auto Scaling Group

- **Resource**: `aws_autoscaling_group.ecs_asg`
- **Description**: Creates an ASG that:
  - Uses ECS launch template
  - Scales between `min_size` and `max_size`
  - Launches into `public_subnets`
  - Tagged as `${environment}-aws-ecs-asg`

### 🔹 Launch Template

- **Resource**: `aws_launch_template.ecs`
- **Description**: EC2 configuration using ECS-optimized AMI with:
  - `instance_type`, `key_name`, security group
  - IAM profile and user data to join ECS cluster
  - Tagged as `${environment}-aws-launch-template-ecs`

### 🔹 ECS Task Definition

- **Resource**: `aws_ecs_task_definition.this`
- **Description**: Defines the ECS task:
  - Container from `docker_image`
  - Port mapping to `target_port`
  - Environment variables for DB and S3
  - Uses `ecs_task_execution_role`
  - Logs to CloudWatch

### 🔹 ECS Service

- **Resource**: `aws_ecs_service.this`
- **Description**: Manages service:
  - Runs desired tasks on ECS cluster
  - Connects to ALB via `target_group_arn`
  - Deploys with 50% min/200% max health constraints

### 🔹 Load Balancer Listener

- **Resource**: `aws_lb_listener.http`
- **Description**: Forwards HTTP traffic on `target_port` to `target_group_arn`.

### 🔹 SSM Parameter (AMI)

- **Resource**: `data.aws_ssm_parameter.this`
- **Description**: Gets latest ECS-optimized AMI from AWS SSM.

---

## ⚠️ Notes

- **Scaling**: ASG and ECS service ensure task availability with EC2 health checks.
- **Security**: Use restricted security groups; consider private subnets in production.
- **Logging**: Containers log to CloudWatch Logs in `eu-central-1`.
- **Dependencies**: Listener depends on ALB to ensure correct provisioning order.
- **Production Tips**:
  - Use Secrets Manager for credentials
  - Consider **Fargate** or private networking for added security

---