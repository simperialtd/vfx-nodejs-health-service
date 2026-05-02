module "nic_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "network-interface"
}

module "osdisk_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "osdisk"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(timestamp(), "2h")
}

resource "random_string" "avd_local_passwd" {
  count            = var.number_of_session_hosts
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

resource "azurerm_network_interface" "this" {
  count               = var.number_of_session_hosts
  name                = "${module.nic_naming.resource_name_prefix}-${var.session_hosts_preffix}-${count.index}"
  resource_group_name = var.session_hosts_resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "nic${count.index}_config"
    subnet_id                     = var.session_hosts_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count                 = var.number_of_session_hosts
  name                  = "${var.session_hosts_preffix}-${count.index}"
  resource_group_name   = var.session_hosts_resource_group_name
  location              = var.location
  size                  = var.session_hosts_vm_size
  network_interface_ids = ["${azurerm_network_interface.this.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.session_hosts_local_admin_username
  admin_password        = random_string.avd_local_passwd[count.index].result

  os_disk {
    name                 = "${module.osdisk_naming.resource_name_prefix}-${var.session_hosts_preffix}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.session_hosts_source_image_reference.publisher
    offer     = var.session_hosts_source_image_reference.offer
    sku       = var.session_hosts_source_image_reference.sku
    version   = var.session_hosts_source_image_reference.version
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "register_session_host" {
  count                      = var.number_of_session_hosts
  name                       = "RegisterSessionHost"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.this.name}",
        "aadJoin": true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
    }
  }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.number_of_session_hosts
  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.2"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.*.id[count.index]
  auto_upgrade_minor_version = false
  depends_on                 = [azurerm_virtual_machine_extension.register_session_host]
}