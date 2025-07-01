#!/bin/bash

# Terraform Deployment Script for Java App Infrastructure
set -e

echo "🚀 Starting Terraform deployment for Java App infrastructure..."

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please create it from terraform.tfvars.example"
    echo "   cp terraform.tfvars.example terraform.tfvars"
    echo "   # Edit terraform.tfvars with your values"
    exit 1
fi

# Check if user is logged into Azure
echo "🔍 Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "❌ Not logged into Azure. Please run: az login"
    exit 1
fi

echo "✅ Azure login verified"

# Step 1: Setup backend storage (if not already done)
echo "📦 Setting up Terraform backend storage..."
if [ ! -d "backend" ]; then
    echo "❌ Backend directory not found. Please ensure backend/main.tf exists"
    exit 1
fi

cd backend
if [ ! -f ".terraform.lock.hcl" ]; then
    echo "🔧 Initializing backend setup..."
    terraform init
fi

echo "🏗️  Creating backend storage resources..."
terraform plan -out=backend.tfplan
terraform apply backend.tfplan

# Get backend configuration
echo "📋 Getting backend configuration..."
BACKEND_CONFIG=$(terraform output -json backend_config)
RESOURCE_GROUP=$(echo $BACKEND_CONFIG | jq -r '.resource_group_name')
STORAGE_ACCOUNT=$(echo $BACKEND_CONFIG | jq -r '.storage_account_name')
CONTAINER_NAME=$(echo $BACKEND_CONFIG | jq -r '.container_name')
KEY=$(echo $BACKEND_CONFIG | jq -r '.key')

echo "✅ Backend storage created:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Storage Account: $STORAGE_ACCOUNT"
echo "   Container: $CONTAINER_NAME"

cd ..

# Step 2: Configure main Terraform with backend
echo "🔧 Configuring main Terraform with remote backend..."

# Update main.tf with backend configuration
sed -i.bak "s|# backend \"azurerm\" {|backend \"azurerm\" {|g" main.tf
sed -i.bak "s|#   resource_group_name  = \"terraform-state-rg\"|  resource_group_name  = \"$RESOURCE_GROUP\"|g" main.tf
sed -i.bak "s|#   storage_account_name = \"tfstateXXXXX\"|  storage_account_name = \"$STORAGE_ACCOUNT\"|g" main.tf
sed -i.bak "s|#   container_name       = \"tfstate\"|  container_name       = \"$CONTAINER_NAME\"|g" main.tf
sed -i.bak "s|#   key                  = \"java-app.terraform.tfstate\"|  key                  = \"$KEY\"|g" main.tf
sed -i.bak "s|# }|}|g" main.tf

echo "✅ Backend configuration updated in main.tf"

# Step 3: Initialize main Terraform with backend
echo "🔧 Initializing main Terraform configuration..."
terraform init

# Step 4: Plan and apply main infrastructure
echo "📋 Planning main infrastructure deployment..."
terraform plan -out=main.tfplan

echo "🏗️  Applying main infrastructure..."
terraform apply main.tfplan

# Step 5: Display important outputs
echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Important Information:"
echo "========================"

echo ""
echo "🔐 GitHub Actions Credentials (add to GitHub Secrets as AZURE_CREDENTIALS):"
echo "$(terraform output -raw github_actions_credentials)"

echo ""
echo "🔧 CI/CD Environment Variables:"
terraform output -json ci_cd_environment_variables | jq -r 'to_entries[] | "\(.key)=\(.value)"'

echo ""
echo "☸️  Configure kubectl:"
echo "$(terraform output -raw kubectl_config_command)"

echo ""
echo "🌐 Next Steps:"
echo "1. Add the GitHub Actions credentials to your repository secrets"
echo "2. Update your CI/CD pipeline with the environment variables above"
echo "3. Configure kubectl using the command above"
echo "4. Test your deployment pipeline"

echo ""
echo "✅ All done! Your Azure infrastructure is ready for CI/CD."
