# Azure Setup Guide for CI/CD Pipeline

## Prerequisites
- Azure CLI installed and configured
- kubectl installed
- GitHub repository with admin access

## 1. Create Azure Resources

### Create Resource Group
```bash
az group create --name your-resource-group --location eastus
```

### Create Azure Container Registry (ACR)
```bash
az acr create --resource-group your-resource-group --name your-acr-name --sku Basic
```

### Create AKS Cluster
```bash
az aks create \
  --resource-group your-resource-group \
  --name your-aks-cluster \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --attach-acr your-acr-name
```

### Get AKS Credentials
```bash
az aks get-credentials --resource-group your-resource-group --name your-aks-cluster
```

## 2. Create Service Principal for GitHub Actions

### Create Service Principal
```bash
az ad sp create-for-rbac --name "github-actions-sp" --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/your-resource-group \
  --sdk-auth
```

This will output JSON credentials that you'll need for GitHub secrets.

### Grant ACR Push/Pull Permissions
```bash
# Get ACR resource ID
ACR_REGISTRY_ID=$(az acr show --name your-acr-name --resource-group your-resource-group --query id --output tsv)

# Get service principal ID
SP_ID=$(az ad sp list --display-name "github-actions-sp" --query [0].objectId --output tsv)

# Assign AcrPush role
az role assignment create --assignee $SP_ID --scope $ACR_REGISTRY_ID --role AcrPush
```

## 3. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

### AZURE_CREDENTIALS
Copy the entire JSON output from the service principal creation step above.

Example format:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## 4. Update Environment Variables

In your `.github/workflows/ci.yml` file, update these environment variables:

```yaml
env:
  AZURE_CONTAINER_REGISTRY: your-acr-name.azurecr.io
  CONTAINER_NAME: java-app
  RESOURCE_GROUP: your-resource-group
  CLUSTER_NAME: your-aks-cluster
```

Replace:
- `your-acr-name` with your actual ACR name
- `your-resource-group` with your actual resource group name
- `your-aks-cluster` with your actual AKS cluster name

## 5. Update Kubernetes Manifest

In `k8s/deployment.yaml`, update the image reference:
```yaml
image: your-acr-name.azurecr.io/java-app:latest
```

## 6. Test the Pipeline

1. Commit and push your changes to the master branch
2. Check the GitHub Actions tab to monitor the pipeline execution
3. Verify the deployment in AKS:

```bash
kubectl get deployments
kubectl get services
kubectl get pods
```

## 7. Access Your Application

Get the external IP of your service:
```bash
kubectl get service java-app-service
```

Once the EXTERNAL-IP is assigned, you can access your application at that IP address.

## Troubleshooting

### Check pod logs
```bash
kubectl logs -l app=java-app
```

### Check deployment status
```bash
kubectl describe deployment java-app-deployment
```

### Check service status
```bash
kubectl describe service java-app-service
```
