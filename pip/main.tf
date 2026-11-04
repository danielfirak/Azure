resource "azurerm_public_ip" "this" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = var.allocation_method
  sku                     = var.sku
  sku_tier                = var.sku_tier
  ip_version              = var.ip_version
  domain_name_label       = var.domain_name_label
  zones                   = var.zones
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  tags = var.tags
}