
# VPC Module

This Terraform module creates an AWS Virtual Private Cloud (VPC) with a specified CIDR block, along with public and private subnets distributed across availability zones. The module is designed to provide a foundational network infrastructure for applications, ensuring separation between public-facing and private resources.

---

## 📥 Inputs

| Name          | Type          | Description                                                                 |
|---------------|---------------|-----------------------------------------------------------------------------|
| `cidr_block`  | `string`      | The CIDR block for the VPC (e.g., `"10.0.0.0/16"`).                         |
| `environment` | `string`      | The environment name (e.g., `"dev"`, `"prod"`).                             |
| `tags`        | `map(string)` | Additional tags to apply to all resources.                                  |
| `subnet_count`| `number`      | The number of public and private subnets to create.                         |
| `azs`         | `list(string)`| List of availability zones to distribute subnets across.                    |

---

## 📤 Outputs

| Name              | Description                                 |
|-------------------|---------------------------------------------|
| `vpc_id`          | The ID of the created VPC.                  |
| `public_subnets`  | List of public subnet IDs.                  |
| `private_subnets` | List of private subnet IDs.                 |

---

## 🚀 Usage

```hcl
module "vpc" {
  source       = "./modules/vpc"
  cidr_block   = "10.0.0.0/16"
  environment  = "dev"
  subnet_count = 2
  azs          = ["eu-central-1a", "eu-central-1b"]
  tags         = {
    Project = "grocery-app"
  }
}
```

This configuration creates:

- A VPC with the CIDR block `10.0.0.0/16`
- Two public subnets and two private subnets
- Subnets distributed across the `eu-central-1a` and `eu-central-1b` availability zones
- Resources tagged with `environment = dev` and `Project = grocery-app`

---

## 🏗️ Resources Created

### VPC  
**Resource**: `aws_vpc.this`  
Creates a VPC with the specified `cidr_block`, DNS support, and environment-based tagging (e.g., `dev-vpc`).

### Public Subnets  
**Resource**: `aws_subnet.public`  
Creates a set of public subnets with:
- Assignment to the created VPC
- Calculated CIDR blocks from the VPC's range
- Distribution across specified AZs
- `map_public_ip_on_launch = true` for auto-assigned public IPs
- Tagged with names like `dev-public-0`, `dev-public-1`, etc.

### Private Subnets  
**Resource**: `aws_subnet.private`  
Creates private subnets with:
- Assignment to the created VPC
- Calculated CIDR blocks from the VPC's range
- Distribution across specified AZs
- `map_public_ip_on_launch = false`
- Tagged with names like `dev-private-0`, `dev-private-1`, etc.

---

## 📝 Notes

- **Subnet Calculation**: Subnet CIDRs are calculated using the `cidrsubnet` function. For example:
  - VPC CIDR `10.0.0.0/16` with `subnet_count = 2` results in:
    - Public: `10.0.0.0/24`, `10.0.1.0/24`
    - Private: `10.0.2.0/24`, `10.0.3.0/24`

- **Availability Zones**: Subnets are evenly distributed across provided AZs. If `subnet_count` exceeds the number of AZs, it wraps around using modulo indexing.

- **Flexibility**: The module supports customization via variables, making it adaptable for different environments and architectures.

---

This module provides a simple yet powerful way to establish a secure, well-structured VPC suitable for hosting a wide range of AWS workloads.
