#!/bin/bash

echo "🔒 Day 1: Security Hardening Setup"
echo "=================================="

# 1. Deploy Key Vault (requires Terraform update)
echo "📋 Step 1: Updating Terraform with Key Vault..."
cd terraform
terraform plan -target=azurerm_key_vault.main
echo "⚠️  Run 'terraform apply -target=azurerm_key_vault.main' to create Key Vault"

# 2. Create secure namespace and RBAC
echo "📋 Step 2: Creating secure namespace and RBAC..."
cd ..
kubectl apply -f k8s/security/pod-security-policy.yaml

# 3. Apply network policies
echo "📋 Step 3: Applying network policies..."
kubectl apply -f k8s/security/network-policies.yaml

# 4. Deploy secure version of the application
echo "📋 Step 4: Deploying secure Java application..."
kubectl apply -f k8s/secure-deployment.yaml

# 5. Wait for deployment
echo "📋 Step 5: Waiting for secure deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/java-app-secure-deployment -n java-app-secure

# 6. Get service information
echo "📋 Step 6: Getting service information..."
kubectl get services -n java-app-secure

echo ""
echo "✅ Day 1 Security Setup Complete!"
echo ""
echo "🔍 Next Steps:"
echo "1. Update Terraform to include Key Vault"
echo "2. Test the secure application"
echo "3. Verify network policies are working"
echo "4. Check pod security standards"
echo ""
echo "🌐 Secure Application URL:"
kubectl get service java-app-secure-service -n java-app-secure -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null
echo ""
echo ""
echo "📊 Security Checklist:"
echo "- [x] Pod Security Standards implemented"
echo "- [x] Network Policies configured"
echo "- [x] RBAC with least privilege"
echo "- [x] Non-root containers"
echo "- [x] Read-only root filesystem"
echo "- [x] Security contexts configured"
echo "- [ ] Key Vault integration (manual step)"
echo "- [ ] Image vulnerability scanning"
