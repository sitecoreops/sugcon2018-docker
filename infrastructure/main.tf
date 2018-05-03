provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  version         = ">= 1.3.2"
}

data "azurerm_resource_group" "main" {
  name = "${var.resource_group_name}"
}

module "network" {
  source              = "./network"
  prefix              = "net"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}

resource "azurerm_availability_set" "build" {
  name                         = "build-as"
  location                     = "${data.azurerm_resource_group.main.location}"
  resource_group_name          = "${data.azurerm_resource_group.main.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

module "build_windows_vm" {
  source                    = "./windows"
  count                     = 1
  prefix                    = "build-winvm"
  location                  = "${data.azurerm_resource_group.main.location}"
  resource_group_name       = "${data.azurerm_resource_group.main.name}"
  availability_set_id       = "${azurerm_availability_set.build.id}"
  network_security_group_id = "${module.network.network_security_group_id}"
  subnet_id                 = "${module.network.subnet_id}"
  size                      = "${var.build_windows_vm_size}"
  admin_username            = "${var.admin_username}"
  admin_password            = "${var.admin_password}"
}

resource "azurerm_availability_set" "runtime" {
  name                         = "runtime-as"
  location                     = "${data.azurerm_resource_group.main.location}"
  resource_group_name          = "${data.azurerm_resource_group.main.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

module "runtime_windows_vm" {
  source                    = "./windows"
  count                     = "${var.runtime_windows_vm_count}"
  prefix                    = "runtime-winvm"
  location                  = "${data.azurerm_resource_group.main.location}"
  resource_group_name       = "${data.azurerm_resource_group.main.name}"
  availability_set_id       = "${azurerm_availability_set.runtime.id}"
  network_security_group_id = "${module.network.network_security_group_id}"
  subnet_id                 = "${module.network.subnet_id}"
  size                      = "${var.runtime_windows_vm_size}"
  admin_username            = "${var.admin_username}"
  admin_password            = "${var.admin_password}"
}

module "runtime_linux_vm" {
  source                    = "./linux"
  count                     = "${var.runtime_linux_vm_count}"
  prefix                    = "runtime-nixvm"
  location                  = "${data.azurerm_resource_group.main.location}"
  resource_group_name       = "${data.azurerm_resource_group.main.name}"
  availability_set_id       = "${azurerm_availability_set.runtime.id}"
  network_security_group_id = "${module.network.network_security_group_id}"
  subnet_id                 = "${module.network.subnet_id}"
  size                      = "${var.runtime_linux_vm_size}"
  admin_username            = "${var.admin_username}"
  admin_password            = "${var.admin_password}"
}
