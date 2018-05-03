output "subnet_id" {
  value = "${azurerm_subnet.net.id}"
}

output "network_security_group_id" {
  value = "${azurerm_network_security_group.net.id}"
}
