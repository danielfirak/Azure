# -----------------------------------------------------------------------------
# Module: cisco_8000v
# Deploys a Cisco Catalyst 8000v router from the Azure Marketplace
# (PAYG, Advantage licence) as a Linux VM.
#
# Before the first apply the subscription must accept the image's marketplace
# terms once, e.g.:
#   az vm image terms accept --publisher cisco --offer cisco-c8000v-payg --plan 26_02_payg-advantage
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  size                = var.vm_size
  # Use the first zone from the list, or no zone if the list is empty
  zone           = length(var.zones) > 0 ? var.zones[0] : null
  admin_username = var.admin_username
  admin_password = var.admin_password
  # First NIC in the list becomes the primary NIC (GigabitEthernet1)
  network_interface_ids = var.network_interface_ids
  # Password login is used, so password authentication must stay enabled
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  # Marketplace image to boot from
  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v-payg"
    sku       = "26_02_payg-advantage"
    version   = "latest"
  }

  # Marketplace purchase plan; must match the image above
  plan {
    name      = "26_02_payg-advantage"
    product   = "cisco-c8000v-payg"
    publisher = "cisco"
  }

  # Secure boot and vTPM are only enabled for Trusted Launch VMs
  secure_boot_enabled = var.security_type == "TrustedLaunch" ? true : false
  vtpm_enabled        = var.security_type == "TrustedLaunch" ? true : false

  # Empty block = use a managed storage account for boot diagnostics
  boot_diagnostics {}

  additional_capabilities {
    hibernation_enabled = var.hibernation_enabled
  }

  tags = var.tags
}
