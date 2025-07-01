terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Remote backend configuration - uncomment and configure after creating storage account
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate54pyh002"  # Replace with unique name
    container_name       = "tfstate"
    key                  = "java-app.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Local values for resource naming
locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${var.project_name}-${var.environment}-rg"
  acr_name           = var.acr_name != "" ? var.acr_name : "${replace(var.project_name, "-", "")}${var.environment}acr${random_string.suffix.result}"
  aks_cluster_name   = var.aks_cluster_name != "" ? var.aks_cluster_name : "${var.project_name}-${var.environment}-aks"
  
  common_tags = merge(var.tags, {
    CreatedBy = "terraform"
    Timestamp = timestamp()
  })
}
