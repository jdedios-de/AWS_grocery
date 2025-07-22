
# S3 Module

This Terraform module creates an AWS S3 bucket with a specified name and an initial folder structure. It is designed to provide storage for application assets, such as user avatars or other data, with customizable tags and environment settings.

---

## 📥 Inputs

| Name          | Type          | Description                                                                  |
|---------------|---------------|------------------------------------------------------------------------------|
| `bucket_name` | `string`      | The name of the S3 bucket (e.g., `"j-grocerymate-avatars"`).                 |
| `folder_name` | `string`      | The name of the folder to create within the bucket (e.g., `"avatars"`).      |
| `environment` | `string`      | The environment name (e.g., `"dev"`, `"prod"`).                              |
| `tags`        | `map(string)` | Additional tags to apply to the S3 bucket.                                   |

---

## 📤 Outputs

| Name        | Description                      |
|-------------|----------------------------------|
| `s3_bucket` | The ARN of the created S3 bucket.|

---

## 🚀 Usage

```hcl
module "s3" {
  source       = "./modules/s3"
  bucket_name  = "j-grocerymate-avatars"
  folder_name  = "avatars"
  environment  = "dev"
  tags         = {
    Project = "grocery-app"
  }
}
```

This configuration creates:

- An S3 bucket named `j-grocerymate-avatars`.
- A folder named `avatars` inside the bucket.
- Resources tagged with the environment name (`dev-s3`) and additional tags (`Project = "grocery-app"`).

---

## 🏗️ Resources Created

### S3 Bucket  
**Resource**: `aws_s3_bucket.avatars`  
- Creates an S3 bucket using the specified `bucket_name`.
- Tags include:
  - `Name = <environment>-s3` (e.g., `dev-s3`)
  - `Environment = "Dev"` (consider making this dynamic)
  - All values in `var.tags`

### S3 Object (Folder)  
**Resource**: `aws_s3_object.folder`  
- Creates a virtual folder inside the S3 bucket.
- Uses `source = "/dev/null"` to simulate an empty folder.
- `content_type = "application/x-directory"` helps represent a folder structure visually.

---

## 📝 Notes

- **Bucket Naming**: `bucket_name` must be globally unique and follow [S3 naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).
- **Folder Creation**: S3 is a flat object store. This module simulates a folder by creating a zero-byte object with the folder name as the key.
- **Security**: This module does **not** configure access controls or policies. Use resources like `aws_s3_bucket_policy` or `aws_s3_bucket_acl` to secure the bucket for production use.

---

This module provides a simple way to establish an S3 bucket with an initial folder structure, suitable for storing application data like avatars in a grocery application.