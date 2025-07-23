# Global Module

This Terraform module serves as a global configuration for an AWS ECS (Elastic Container Service) environment, creating IAM roles, instance profiles, and policies. It includes configurations for ECS instance and task execution roles, as well as an S3 bucket access policy, providing the necessary permissions for EC2 instances and ECS tasks in a grocery application.



---

## 📥 Inputs

| Name                           | Type           | Description                                                                 |
|--------------------------------|----------------|-----------------------------------------------------------------------------|
| `region`                       | `string`       | The AWS region for provider configuration (e.g., `eu-central-1`).                                  |
| `s3_bucket`                  | `string`       | The ARN or name of the S3 bucket to grant access to (e.g., `j-grocerymate-avatars`).       |

---

## 📤 Outputs

| Name                    | Description                                      |
|-------------------------|--------------------------------------------------|
| `ecs_instance_profile_name`               | The name of the ECS instance profile.        |
| `ecs_task_execution_role`          | The ARN of the ECS task execution role.                         |


---

## 🚀 Usage Example

```hcl
module "global" {
  source   = "./global"
  region   = "eu-central-1"
  s3_bucket = module.s3.s3_bucket
}
```
This configuration creates:An ECS instance role and profile for EC2 instances.
An ECS task execution role for task permissions.
An IAM policy and attachment for S3 bucket access.


---

## 🧱 Resources Created

### 🔹 ECS Instance Role
**Resource:** `aws_iam_role.ecs_instance_role`  
**Description:** Creates an IAM role named `ecsInstanceRole` that allows EC2 instances to assume the role, enabling ECS container management.

### 🔹 ECS Instance Role Policy Attachment
**Resource:** `aws_iam_role_policy_attachment.ecs_instance_role_policy`  
**Description:** Attaches the `AmazonEC2ContainerServiceforEC2Role` managed policy to the ECS instance role, granting permissions for ECS on EC2.

### 🔹 ECS Instance Profile
**Resource:** `aws_iam_instance_profile.ecs_instance_profile`  
**Description:** Creates an instance profile named `ecsInstanceProfile` linked to the ECS instance role, used by EC2 instances running ECS.

### 🔹 ECS Task Execution Role
**Resource:** `aws_iam_role.ecs_task_execution_role`  
**Description:** Creates an IAM role named `ecsTaskExecutionRole` that allows ECS tasks to assume the role, enabling task execution and logging.

### 🔹 ECS Task Execution Role Policy Attachment
**Resource:** `aws_iam_role_policy_attachment.ecs_task_execution_role_policy`  
**Description:** Attaches the `AmazonECSTaskExecutionRolePolicy` managed policy to the ECS task execution role, granting permissions for task execution, logging, and secrets access.

### 🔹 S3 Bucket Access Policy
**Resource:** `aws_iam_policy.ec2_s3_bucket_policy`  
**Description:** Creates a custom IAM policy named `AllowEC2ToAccessMyBucket` that allows:
- `s3:GetObject`
- `s3:PutObject`
- `s3:ListBucket`  
Access to the specified `s3_bucket` and its objects (`${s3_bucket}/*`).

### 🔹 S3 Bucket Access Policy Attachment
**Resource:** `aws_iam_role_policy_attachment.ec2_s3_bucket_policy`  
**Description:** Attaches the S3 bucket access policy to the ECS instance role, enabling EC2 instances to interact with the S3 bucket.

### 🔹 AWS Provider
**Resource:** `provider.aws`  
**Description:** Configures the AWS provider with the specified region.

### 🔹 Terraform Configuration
**Resource:** `terraform`  
**Description:** Specifies required Terraform version (`>= 1.2.0`) and AWS provider version (`~> 4.67`).

## 🔹 Notes

- **Security:** The S3 policy restricts access to the specified `s3_bucket`, but ensure the bucket ARN is correctly passed. Consider using a secrets manager for sensitive data in production.
- **Role Assumptions:** The `assume_role_policy` allows only `ec2.amazonaws.com` and `ecs-tasks.amazonaws.com` as principals, enhancing security.
- **Scalability:** This module is designed as a global configuration, reusable across environments by passing the `region` and `s3_bucket`.
- **Production Considerations:** Use more restrictive IAM policies and rotate credentials regularly. The hardcoded role names (`ecsInstanceRole`, `ecsTaskExecutionRole`) should be parameterized for multi-environment setups.
---