terraform {
  backend "azurerm" {
    storage_account_name = "valtechdkterraformstate"
    container_name       = "sugcon2018-docker"
    key                  = "infrastructure/swarm/terraform.tfstate"
  }
}
