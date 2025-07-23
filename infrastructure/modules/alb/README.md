# ALB Module

This Terraform module creates an **AWS Application Load Balancer (ALB)** along with associated **security groups**, **internet gateway**, **route table**, **listener**, and **target group**. It is designed to manage web traffic for a grocery application, ensuring **scalability**, **security**, and **network routing**.

---

## 📥 Inputs

| Name                           | Type           | Description                                                                 |
|--------------------------------|----------------|-----------------------------------------------------------------------------|
| `vpc_id`                       | `string`       | The ID of the VPC to deploy resources in.                                   |
| `target_port`                  | `number`       | The port for the ALB, target group, and health checks (e.g., `5000`).       |
| `health_check_path`           | `string`       | The path for health checks (e.g., `"/health"`).                             |
| `health_check_matcher`        | `string`       | The HTTP status codes considered healthy (e.g., `"200-399"`).               |
| `health_check_interval`       | `number`       | The interval between health checks in seconds (e.g., `30`).                 |
| `health_check_healthy_threshold` | `number`    | The number of consecutive successful checks to mark healthy (e.g., `2`).    |
| `health_check_unhealthy_threshold` | `number`  | The number of consecutive failed checks to mark unhealthy (e.g., `3`).      |
| `health_check_timeout`        | `number`       | The timeout for health checks in seconds (e.g., `3`).                       |
| `environment`                 | `string`       | The environment name (e.g., `"dev"`, `"prod"`).                             |
| `tags`                        | `map(string)`  | Additional tags to apply to resources.                                      |
| `subnet_count`                | `number`       | The number of public subnets to associate with the ALB.                     |
| `public_subnets`              | `list(string)` | List of public subnet IDs for the ALB.                                      |
| `admin_cidr`                  | `string`       | The CIDR range for admin SSH access (default: `"80.141.136.240/32"`).       |

---

## 📤 Outputs

| Name                    | Description                                      |
|-------------------------|--------------------------------------------------|
| `alb_arn`               | The ARN of the Application Load Balancer.        |
| `alb_dns_name`          | The DNS name of the ALB.                         |
| `target_group_arn`      | The ARN of the target group.                     |
| `alb_ec2_security_group`| The ID of the EC2 security group.                |
| `alb_rds_security_group`| The ID of the RDS security group.                |

---

## 🚀 Usage Example

```hcl
module "alb" {
  source                        = "./modules/alb"
  vpc_id                        = module.vpc.vpc_id
  target_port                   = 5000
  health_check_path             = "/health"
  health_check_matcher          = "200-399"
  health_check_interval         = 30
  health_check_healthy_threshold = 2
  health_check_unhealthy_threshold = 3
  health_check_timeout          = 3
  environment                   = "dev"
  tags                          = { Project = "grocery-app" }
  subnet_count                  = 2
  public_subnets                = module.vpc.public_subnets
  admin_cidr                    = "XX.XX.136.240/32"
}
```

---

## 🧱 Resources Created

### 🔹 ALB Security Group

- **Resource**: `aws_security_group.alb_sg`
- **Description**: Allows HTTP (80) and HTTPS (443), and `target_port` access from 0.0.0.0/0. Tagged as `${environment}-alb-sg`.

### 🔹 EC2 Security Group

- **Resource**: `aws_security_group.ec2_sg`
- **Description**: Allows SSH (22) from `admin_cidr`, HTTP/HTTPS/`target_port` from 0.0.0.0/0, all outbound traffic. Tagged as `${environment}-aws-ec2-sg`.

### 🔹 RDS Security Group

- **Resource**: `aws_security_group.rds_sg`
- **Description**: Allows PostgreSQL (5432) from the EC2 security group. Tagged as `${environment}-aws-rds-sg`.

### 🔹 Internet Gateway

- **Resource**: `aws_internet_gateway.public`
- **Description**: Public internet access for the VPC. Tagged as `${environment}-igw`.

### 🔹 Load Balancer

- **Resource**: `aws_lb.this`
- **Description**: Public ALB named `${environment}-alb`, using public subnets and ALB SG.

### 🔹 Target Group

- **Resource**: `aws_lb_target_group.this`
- **Description**: ALB target group named `${environment}-tg`, with health checks configured. Tagged as `${environment}-ecs-tg`.

### 🔹 Listener

- **Resource**: `aws_lb_listener.this`
- **Description**: Listens on `target_port` and forwards to the target group. Tagged as `${environment}-lb-listener`.

### 🔹 Route Table

- **Resource**: `aws_route_table.public`
- **Description**: Adds default route to the internet gateway and associates with public subnets.

---

## ⚠️ Notes

- **Security**: Broad access (0.0.0.0/0) is used for ALB and EC2 — restrict in production (e.g., WAF or specific CIDRs).
- **Health Checks**: Fully configurable to ensure application availability and resilience.
- **Routing**: Enables public internet access for services via the route table and gateway.
- **Admin Access**: Admin SSH access is restricted to `admin_cidr`.
- **Production Tips**:
  - Use HTTPS with a certificate for secure traffic.
  - Harden `target_port` and `admin_cidr` settings.

---