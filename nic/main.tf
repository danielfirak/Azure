resource "azurerm_network_interface" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.rg_name
  accelerated_networking_enabled = var.enable_accelerated_networking
  #network_security_group_id     = var.nsg_id

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = var.nsg_id
}