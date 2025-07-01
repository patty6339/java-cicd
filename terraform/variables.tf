variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
  default     = "java-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = ""
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = ""
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = ""
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = null
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for AKS node pool"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "Minimum number of nodes for auto scaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for auto scaling"
  type        = number
  default     = 5
}

variable "github_actions_sp_name" {
  description = "Name for the GitHub Actions service principal"
  type        = string
  default     = "github-actions-sp"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "java-app"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Environment-specific configurations
locals {
  environment_config = {
    dev = {
      node_count           = 2
      node_vm_size        = "Standard_D2s_v3"
      acr_sku             = "Basic"
      enable_auto_scaling = false
      min_count           = 1
      max_count           = 3
      enable_network_policy = true
      log_retention_days   = 30
    }
    staging = {
      node_count           = 3
      node_vm_size        = "Standard_D2s_v3"
      acr_sku             = "Standard"
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 5
      enable_network_policy = true
      log_retention_days   = 60
    }
    prod = {
      node_count           = 5
      node_vm_size        = "Standard_D4s_v3"
      acr_sku             = "Premium"
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 10
      enable_network_policy = true
      log_retention_days   = 90
    }
  }
  
  current_config = local.environment_config[var.environment]
}

# Backend configuration is handled separately in backend/ directory
