resource "azurerm_network_interface" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = var.enable_accelerated_networking
  network_security_group_id     = var.nsg_id

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = var.tags
}