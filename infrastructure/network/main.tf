resource "azurerm_virtual_network" "net" {
  name                = "${var.prefix}-vnet"
  address_space       = ["172.17.0.0/16"]
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
}

resource "azurerm_subnet" "net" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = "${azurerm_virtual_network.net.name}"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "172.17.1.0/24"
}

resource "azurerm_network_security_group" "net" {
  name                = "${var.prefix}-nsg"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"

  security_rule {
    name                       = "XXX"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "x.x.x.x"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "YYY"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "y.y.y.y"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
}
