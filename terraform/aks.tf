# Azure Kubernetes Service Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.enable_auto_scaling ? null : var.aks_node_count
    vm_size             = var.aks_node_vm_size
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"

    # Enable node public IP for development (disable for production)
    enable_node_public_ip = var.environment == "dev" ? true : false

    upgrade_settings {
      max_surge = "10%"
    }

    tags = local.common_tags
  }

  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  # Enable monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  # Enable Azure Policy for Kubernetes
  azure_policy_enabled = true

  # HTTP application routing is deprecated - use Application Routing add-on instead
  # http_application_routing_enabled = false

  # Application Routing add-on (replacement for HTTP application routing)
  web_app_routing {
    dns_zone_ids = []  # Optional: specify DNS zone IDs for custom domains
  }

  # Role-based access control
  role_based_access_control_enabled = true

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      tags["Timestamp"],
      default_node_pool[0].node_count
    ]
  }

  depends_on = [
    azurerm_log_analytics_workspace.main
  ]
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-${var.environment}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags["Timestamp"]]
  }
}
