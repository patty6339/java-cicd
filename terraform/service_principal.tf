# Azure AD Application for GitHub Actions
resource "azuread_application" "github_actions" {
  display_name = "${var.github_actions_sp_name}-${var.environment}"
  owners       = [data.azurerm_client_config.current.object_id]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

# Service Principal for the Azure AD Application
resource "azuread_service_principal" "github_actions" {
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# Service Principal Password (Client Secret)
resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.object_id
  display_name         = "GitHub Actions Secret"
  end_date_relative    = "8760h" # 1 year
}

# Role Assignment: Contributor on Resource Group
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Role Assignment: AcrPush on Container Registry
resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id

  depends_on = [azurerm_container_registry.main]
}

# Role Assignment: Azure Kubernetes Service Cluster User Role
resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.github_actions.object_id

  depends_on = [azurerm_kubernetes_cluster.main]
}
