# -----------------------------------------------------------------------------
# Module: pip
# Creates one public IP address. Defaults (Static, Standard, Regional, IPv4)
# are what Azure Route Server requires; see variables.tf.
# -----------------------------------------------------------------------------

resource "azurerm_public_ip" "this" {
  name                    = var.name
  resource_group_name     = var.rg_name
  location                = var.location
  allocation_method       = var.allocation_method
  sku                     = var.sku
  sku_tier                = var.sku_tier
  ip_version              = var.ip_version
  domain_name_label       = var.domain_name_label # optional DNS label -> <label>.<region>.cloudapp.azure.com
  zones                   = var.zones             # null = no zone
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  tags                    = var.tags
}
