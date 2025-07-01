# Terraform Infrastructure for Java App CI/CD

This Terraform configuration provisions Azure resources for a Java application CI/CD pipeline including:

- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- Service Principal for GitHub Actions
- Log Analytics Workspace for monitoring
- Remote backend for Terraform state management

## Prerequisites

1. **Azure CLI** installed and authenticated
   ```bash
   az login
   ```

2. **Terraform** installed (version >= 1.0)
   ```bash
   terraform version
   ```

3. **Required Azure permissions**:
   - Contributor role on the subscription
   - Application Administrator role in Azure AD (for service principal creation)

## Quick Start

### Step 1: Setup Remote Backend (First Time Only)

1. Create a copy of the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your desired values.

3. Initialize and create the backend storage:
   ```bash
   terraform init
   terraform plan -target=azurerm_resource_group.terraform_state -target=azurerm_storage_account.terraform_state -target=azurerm_storage_container.terraform_state
   terraform apply -target=azurerm_resource_group.terraform_state -target=azurerm_storage_account.terraform_state -target=azurerm_storage_container.terraform_state
   ```

4. Get the backend configuration:
   ```bash
   terraform output backend_config_block
   ```

5. Update `main.tf` by uncommenting and configuring the backend block with the output values.

6. Reinitialize Terraform with the remote backend:
   ```bash
   terraform init -migrate-state
   ```

### Step 2: Deploy Infrastructure

1. Plan the deployment:
   ```bash
   terraform plan
   ```

2. Apply the configuration:
   ```bash
   terraform apply
   ```

3. Get the outputs:
   ```bash
   terraform output
   ```

## Configuration Files

### Core Files
- `main.tf` - Main Terraform configuration and providers
- `variables.tf` - Input variables definitions
- `outputs.tf` - Output values definitions
- `terraform.tfvars` - Variable values (create from example)

### Resource Files
- `resource_group.tf` - Azure Resource Group
- `acr.tf` - Azure Container Registry
- `aks.tf` - Azure Kubernetes Service and Log Analytics
- `service_principal.tf` - GitHub Actions Service Principal
- `backend_setup.tf` - Remote backend storage resources

## Important Outputs

After deployment, you'll get several important outputs:

### GitHub Actions Configuration
```bash
# Get the credentials for GitHub Actions secret
terraform output -raw github_actions_credentials
```

### Kubernetes Configuration
```bash
# Configure kubectl
terraform output -raw kubectl_config_command
```

### CI/CD Environment Variables
```bash
# Get environment variables for your CI/CD pipeline
terraform output ci_cd_environment_variables
```

## GitHub Actions Setup

1. **Add Azure Credentials Secret**:
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Add a new secret named `AZURE_CREDENTIALS`
   - Use the value from: `terraform output -raw github_actions_credentials`

2. **Update CI/CD Pipeline**:
   Update your `.github/workflows/ci.yml` with the environment variables from:
   ```bash
   terraform output ci_cd_environment_variables
   ```

## Post-Deployment Steps

1. **Configure kubectl**:
   ```bash
   # Run the command from terraform output
   az aks get-credentials --resource-group <resource-group> --name <aks-cluster>
   ```

2. **Verify AKS cluster**:
   ```bash
   kubectl get nodes
   kubectl get namespaces
   ```

3. **Test ACR access**:
   ```bash
   az acr login --name <acr-name>
   ```

## Resource Naming Convention

Resources are named using the pattern: `{project_name}-{environment}-{resource_type}`

Example with `project_name = "java-app"` and `environment = "dev"`:
- Resource Group: `java-app-dev-rg`
- AKS Cluster: `java-app-dev-aks`
- ACR: `javaappdevacr{random_suffix}`

## Environment-Specific Configurations

### Development Environment
- HTTP application routing enabled
- Node public IPs enabled
- Basic ACR SKU
- Smaller node sizes

### Production Environment
- Content trust enabled for ACR
- HTTP application routing disabled
- Node public IPs disabled
- Premium ACR SKU recommended
- Larger node sizes and auto-scaling

## Cost Optimization

- **AKS**: Use auto-scaling to optimize node usage
- **ACR**: Basic SKU for development, Standard/Premium for production
- **Log Analytics**: 30-day retention to control costs
- **Node Sizes**: Start with Standard_DS2_v2, scale as needed

## Security Best Practices

- Service principal has minimal required permissions
- ACR admin access is enabled (disable in production if using managed identity)
- RBAC is enabled on AKS cluster
- Azure Policy is enabled for compliance

## Troubleshooting

### Common Issues

1. **Service Principal Creation Fails**:
   - Ensure you have Application Administrator role in Azure AD
   - Check if the service principal name already exists

2. **AKS Creation Fails**:
   - Verify subscription quotas for VM cores
   - Check if the DNS prefix is unique

3. **Backend State Lock**:
   ```bash
   terraform force-unlock <lock-id>
   ```

### Useful Commands

```bash
# Show current state
terraform show

# List resources
terraform state list

# Get specific output
terraform output <output_name>

# Refresh state
terraform refresh

# Import existing resource
terraform import <resource_type>.<name> <azure_resource_id>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the AKS cluster and container registry. Make sure to backup any important data first.

## Support

For issues with this Terraform configuration:
1. Check the troubleshooting section above
2. Review Terraform and Azure provider documentation
3. Check Azure resource quotas and permissions
