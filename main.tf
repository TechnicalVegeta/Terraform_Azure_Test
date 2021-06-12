provider "azurerm" {
  features {}
}

terraform {
backend "azurerm" {
resource_group_name  = "StorageAccount-ResourceGroup"
storage_account_name = "tfstateaccount"
container_name = "tfstate"
key = "terraform.tfstate"
}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = "devopsteststore1"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "azuretest-vnet"
  address_space       = var.vnet_prefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnets" {
  count             = length(var.subnet_prefixes)
  name              = "subnet-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix    = element(var.subnet_prefixes, count.index)
}

resource "azurerm_network_interface" "nics" {
  count             = length(var.nics)
  name              = "nic-${count.index}"
  location          = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name            = "config-${count.index}"
    subnet_id       = element(azurerm_subnet.subnets[*].id, count.index % 2)
    private_ip_address_allocation = "Static"
    private_ip_address = element(var.nics, count.index)
  }
}
resource "azurerm_network_security_group" "nsg" {
  count               = length(var.subnet_prefix)
  name                = "${element(var.subnet_subnetname, count.index)}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = ["80", "443"]
    destination_port_range     = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "snet_nsg_association" {
  count                     = length(var.subnet_prefix)
  subnet_id                 = element(azurerm_subnet.subnets.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}

# To access stored password from keyvalut

data "azurerm_key_vault_secret" "vmpassword" {
name = "vmpassword"
vault_uri = "https://myKeyVaultName.vault.azure.net/"
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2
  name                = "azurevm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "${data.azurerm_key_vault_secret.vmpassword.value}"
  network_interface_ids = element(local.vm_nics, count.index)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}