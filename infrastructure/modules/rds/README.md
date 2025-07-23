# RDS Module

This Terraform module provisions an **AWS RDS instance** along with a corresponding **database subnet group**, designed to support managed relational databases for applications such as a grocery service. It deploys the database into a **VPC's private subnets** to ensure secure and isolated operations.

---

## 📥 Inputs

| Name                   | Type           | Description                                                                 |
|------------------------|----------------|-----------------------------------------------------------------------------|
| `storage_type`         | `string`       | The storage type for the RDS instance (e.g., `"gp2"`).                      |
| `alloc_storage`        | `number`       | The allocated storage size in GB (e.g., `10`).                              |
| `engine`               | `string`       | The database engine (e.g., `"postgres"`).                                   |
| `eng_version`          | `string`       | The engine version (e.g., `"14.17"`).                                       |
| `instance_class`       | `string`       | The instance type (e.g., `"db.t3.micro"`).                                  |
| `db_name`              | `string`       | The name of the database (e.g., `"grocerymate_db"`).                        |
| `username`             | `string`       | The database admin username (e.g., `"grocery_user"`).                       |
| `password`             | `string`       | The database admin password (e.g., `"grocery_test"`).                       |
| `environment`          | `string`       | The environment name (e.g., `"dev"`, `"prod"`).                             |
| `vpc_security_group_ids` | `list(string)` | List of VPC security group IDs to associate with RDS.                       |
| `private_subnets`      | `list(string)` | List of private subnet IDs for the subnet group.                            |
| `tags`                 | `map(string)`  | Additional tags to apply to the RDS instance.                               |

---

## 📤 Outputs

| Name              | Description                                      |
|-------------------|--------------------------------------------------|
| `db_endpoint`     | The endpoint address of the RDS instance.        |
| `db_subnet_group` | The name of the created database subnet group.   |

---

## 🚀 Usage Example

```hcl
module "rds" {
  source                 = "./modules/rds"
  storage_type           = "gp2"
  alloc_storage          = 10
  engine                 = "postgres"
  eng_version            = "14.17"
  instance_class         = "db.t3.micro"
  db_name                = "grocerymate_db"
  username               = "grocery_user"
  password               = "grocery_test"
  environment            = "dev"
  vpc_security_group_ids = [module.alb.alb_rds_security_group]
  private_subnets        = module.vpc.private_subnets
  tags = {
    Project = "grocery-app"
  }
}
```

This configuration creates:

- A **database subnet group** named `dev-db-subnet-group` using specified private subnets.
- An **RDS instance** named `dev-db` with PostgreSQL 14.17, 10 GB storage, and `db.t3.micro` instance type.
- Resources tagged with environment name (`dev-rds`) and custom tags (e.g., `Project = "grocery-app"`).

---

## 🧱 Resources Created

### 🔹 Database Subnet Group

- **Resource**: `aws_db_subnet_group.this`
- **Description**: Creates a subnet group for the RDS instance, named `${environment}-db-subnet-group` (e.g., `dev-db-subnet-group`).

### 🔹 RDS Instance

- **Resource**: `aws_db_instance.this`
- **Description**: Provisions the RDS instance with the following:
  - Identifier: `${environment}-db` (e.g., `dev-db`)
  - Storage type, engine, version, and class as configured
  - Credentials: `username` and `password`
  - Associated with the subnet group and `vpc_security_group_ids`
  - `skip_final_snapshot = true` for simplicity (not recommended in production)
  - Tags: Named `${environment}-rds` and merged with additional `tags`

---

## ⚠️ Notes

- **Security**: Ensure `vpc_security_group_ids` are configured to restrict access (e.g., allow only from ALB or ECS cluster). Use AWS Secrets Manager to store sensitive credentials in production.
- **Private Subnets**: The RDS instance resides in private subnets, requiring a NAT gateway or VPC endpoint for management access.
- **Snapshot Behavior**: `skip_final_snapshot = true` skips snapshot creation on deletion. Enable snapshots in production for data backup.
- **Scalability**: Tune `instance_class` and `alloc_storage` to meet performance needs.

---