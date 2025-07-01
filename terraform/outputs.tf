output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for ACR"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_node_resource_group" {
  description = "Resource group containing AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "aks_kube_config" {
  description = "Kubernetes configuration for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "service_principal_client_id" {
  description = "Client ID of the GitHub Actions service principal"
  value       = azuread_application.github_actions.client_id
}

output "service_principal_object_id" {
  description = "Object ID of the GitHub Actions service principal"
  value       = azuread_service_principal.github_actions.object_id
}

output "service_principal_client_secret" {
  description = "Client secret for the GitHub Actions service principal"
  value       = azuread_service_principal_password.github_actions.value
  sensitive   = true
}

output "github_actions_credentials" {
  description = "JSON credentials for GitHub Actions (AZURE_CREDENTIALS secret)"
  value = jsonencode({
    clientId       = azuread_application.github_actions.client_id
    clientSecret   = azuread_service_principal_password.github_actions.value
    subscriptionId = data.azurerm_client_config.current.subscription_id
    tenantId       = data.azurerm_client_config.current.tenant_id
  })
  sensitive = true
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for the AKS cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "ci_cd_environment_variables" {
  description = "Environment variables for CI/CD pipeline"
  value = {
    AZURE_CONTAINER_REGISTRY = azurerm_container_registry.main.login_server
    CONTAINER_NAME          = var.project_name
    RESOURCE_GROUP          = azurerm_resource_group.main.name
    CLUSTER_NAME            = azurerm_kubernetes_cluster.main.name
  }
}
