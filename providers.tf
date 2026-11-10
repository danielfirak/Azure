# -----------------------------------------------------------------------------
# Terraform & provider configuration
# -----------------------------------------------------------------------------
terraform {
  # Minimum Terraform CLI version (needed for optional() object attributes etc.)
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Any 5.x release. Note: since v4 the provider requires a subscription ID,
      # e.g. via the ARM_SUBSCRIPTION_ID environment variable.
      version = "~> 5.0"
    }
  }

  # Remote state backend configuration using OIDC & Azure AD authentication.
  # The state file lives in a pre-existing storage account (not managed here).
  backend "azurerm" {
    resource_group_name  = "RG.DFvLAB"
    storage_account_name = "dftestaccount2568"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"

    # Tells the backend to use OIDC token exchange instead of a storage account access key
    use_oidc         = true
    use_azuread_auth = true
  }
}

provider "azurerm" {
  # Required (even if empty) by the azurerm provider
  features {}

  # Tells the AzureRM provider to use OIDC authentication via environment variables
  # (ARM_CLIENT_ID / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID / ARM_USE_OIDC)
  use_oidc = true
}
