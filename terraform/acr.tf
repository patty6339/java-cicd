# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = true

  # Enable content trust for production environments
  trust_policy {
    enabled = var.environment == "prod" ? true : false
  }

  # Retention policy for untagged manifests (Premium SKU only)
  dynamic "retention_policy" {
    for_each = var.acr_sku == "Premium" ? [1] : []
    content {
      enabled = true
      days    = 7
    }
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags["Timestamp"]]
  }
}

# Role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.main,
    azurerm_container_registry.main
  ]
}
