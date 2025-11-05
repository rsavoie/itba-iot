terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    client = "itba"
    project = "iot"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "iot-platform-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "iot-platform-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "iot-platform-101"
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "iot-platform-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  security_rule {
    name                       = "allow_ssh_3000_8000"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3000", "8000"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "iot-platform-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "iot-platform-instance"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_E2s_v3"
  admin_username      = "savoie"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  tags = local.tags

  admin_ssh_key {
    username   = "savoie"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTvXiwypfEAIaCbyQHK/YGl5n2XyRrDhdS5yMQjT++Arzvmn9RrMwyoVmANY8TjbX1UbcUMLwf2AYJb1vCTqD7I/Hs4gCcQVoNnbtHhkMS0A5Frp1Glv2JgNdpjug/owi2x3ku4mMMKlJChCA+mmseOjpa1Yu4qZMICY8toDtDFE4nncbf25x9LvsJlkDqOJ9glBZkDDxENsDOjWEyI5WFNzOLgPbWfYVG8fD/jpTxM1loW2iXVF1Cmacq08LNfVPdRESGB56olNV57NVDTSZwtqFK/XsQu4E6jaqlAHwuXMAEg4xpoF8MDUfn25BWGYkncT5asgXPnPyRkAITP91kRmjlUdg/9Ru+k8D2snKKRK87VTYUGxbaBStkQ7rhUX/pBO9xFPoBrdjkbIQvY8xDgpWXb8XV20XJmBNB1nL/bepa0TKRq4BOrVS8LIWohdmSpngH8yLXD9IFUPzAKiJFb/lE6Gq8F/dWkghZ8Ad6fG3RLOaarfreMSlEky7DLICAdJK74mQpPvAPe1n6M1V4YP3Qpx4hszSCkhHvay3VX75fmsuzCerPylpYVu2zEwh9yT5+7VB+XS9e3H1K7W40e3SQDsqTfcqe2fnY/m7p3kdKXL+e6ZmS8PfnvMIk8liTawd5nIogS+nQnaBj/nTAmk7m479CFY51FGgIAqSgaQ== ramiro@ZenbookS13"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose git openssh-server
  EOT
  )
}
