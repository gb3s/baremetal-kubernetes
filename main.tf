terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bma" {
  name     = "${var.prefix}-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.bma.location
  resource_group_name = azurerm_resource_group.bma.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.bma.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/25"]
}

module "bma" {
  source = "./vms"

  prefix = "bma"
  location = azurerm_resource_group.bma.location
  resource_group = azurerm_resource_group.bma.name
  subnet_id = azurerm_subnet.internal.id
}

module "bma02" {
  source = "./vms"

  prefix = "bma02"
  location = azurerm_resource_group.bma.location
  resource_group = azurerm_resource_group.bma.name
  subnet_id = azurerm_subnet.internal.id
}