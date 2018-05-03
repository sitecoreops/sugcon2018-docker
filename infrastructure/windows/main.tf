resource "azurerm_public_ip" "vm" {
  count                        = "${var.count}"
  name                         = "${var.prefix}${count.index}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.prefix}${count.index}"
}

resource "azurerm_network_interface" "vm" {
  count                     = "${var.count}"
  name                      = "${var.prefix}${count.index}-nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${var.network_security_group_id}"

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                         = "${var.count}"
  name                          = "${var.prefix}${count.index}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  availability_set_id           = "${var.availability_set_id}"
  vm_size                       = "${var.size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServerSemiAnnual"
    sku       = "Datacenter-Core-1709-with-Containers-smalldisk"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "500"
  }

  os_profile {
    computer_name  = "${var.prefix}${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_virtual_machine_extension" "configure" {
  count                      = "${var.count}"
  name                       = "${var.prefix}${count.index}-configure"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
      "commandToExecute": "netsh advfirewall set allprofiles state off & powershell.exe -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -Command Uninstall-WindowsFeature -Name Windows-Defender-Features; Uninstall-WindowsFeature -Name BitLocker; Install-WindowsFeature Hyper-V-PowerShell; Install-Module DockerProvider -Force; Set-WinUserLanguageList -LanguageList DA-DK -Force; Resize-Partition -DriveLetter C -Size ((Get-PartitionSupportedSize -DriveLetter C).SizeMax); Restart-Computer -Force;"
  }
  SETTINGS
}
