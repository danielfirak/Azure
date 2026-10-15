terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state backend configuration using OIDC & Azure AD authentication
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-uks"
    storage_account_name = "stterraformstate01"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    
    # Tells the backend to use OIDC token exchange instead of a storage account access key
    use_oidc         = true
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  
  # Tells the AzureRM provider to use OIDC authentication via environment variables
  use_oidc = true
}
