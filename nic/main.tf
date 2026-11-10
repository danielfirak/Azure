# -----------------------------------------------------------------------------
# Module: nic
# Creates one network interface with a single dynamic IP configuration,
# an optional public IP, and an optional NSG association.
# -----------------------------------------------------------------------------

resource "azurerm_network_interface" "this" {
  name                           = var.name
  location                       = var.location
  resource_group_name            = var.rg_name
  accelerated_networking_enabled = var.accelerated_networking_enabled
  # NSGs cannot be set on the NIC resource itself in azurerm; see the
  # azurerm_network_interface_security_group_association below.
  #network_security_group_id     = var.nsg_id

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    # null = no public IP on this NIC
    public_ip_address_id = var.public_ip_address_id
  }

  tags = var.tags
}

# Attach an existing NSG to the NIC.
# NOTE: this requires nsg_id to be set. To make the NSG optional, add
#   count = var.nsg_id == null ? 0 : 1
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = var.nsg_id
}
