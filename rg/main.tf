# -----------------------------------------------------------------------------
# Module: rg
# Creates the resource group that holds all resources in this deployment.
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
