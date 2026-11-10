resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.rg_name
  size                  = var.vm_size
  zone                  = length(var.zones) > 0 ? var.zones[0] : null
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = var.network_interface_ids
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    delete_option        = var.os_disk_delete_option
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v-payg"
    sku       = "26_02_payg-advantage"
    version   = "latest"
  }

  plan {
    name      = "26_02_payg-advantage"
    product   = "cisco-c8000v-payg"
    publisher = "cisco"
  }

  secure_boot_enabled = var.security_type == "TrustedLaunch" ? true : false
  vtpm_enabled        = var.security_type == "TrustedLaunch" ? true : false

  boot_diagnostics {}

  additional_capabilities {
    hibernation_enabled = var.hibernation_enabled
  }

  tags = var.tags
}