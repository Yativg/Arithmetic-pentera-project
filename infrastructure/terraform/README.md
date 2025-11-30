## Terraform Configuration

### File Structure

- `main.tf` - Infrastructure resources
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars` - Default configuration (committed)
- `terraform.tfvars.local` - Local overrides with secrets (NOT committed)
- `user_data.sh` - EC2 initialization script

### Sensitive Data Management

Sensitive values are managed via `terraform.tfvars.local` which is git-ignored.

**To deploy:**

1. Create `terraform.tfvars.local` with your secrets:
```hcl
jenkins_admin_password = "your-secure-password"
allowed_ssh_cidr = ["your.ip.address/32"]
```

2. Terraform automatically loads both files:
   - `terraform.tfvars` (base config)
   - `terraform.tfvars.local` (your secrets, overrides base)

**Alternative: Environment Variables**

```bash
export TF_VAR_jenkins_admin_password="your-password"
export TF_VAR_allowed_ssh_cidr='["your.ip/32"]'
terraform apply
```

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

