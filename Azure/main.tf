variable "az_subscription_id" {}
variable "az_client_id" {}
variable "az_client_secret" {}
variable "az_tenant_id" {}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.az_subscription_id}"
  client_id       = "${var.az_client_id}"
  client_secret   = "${var.az_client_secret}"
  tenant_id       = "${var.az_tenant_id}"
}

# Create a new resource group in order to isolate the environment
resource "azurerm_resource_group" "abacao-rg" {
  name     = "abacao-rg"
  location = "North Europe"

  tags {
    environment = "Testeabacao"
  }
}

# Create a new storage account because is always required in each zone
resource "azurerm_storage_account" "abacaoStorageAccount" {
  name                = "abacaostorageaccount"
  resource_group_name = "${azurerm_resource_group.abacao-rg.name}"
  location            = "North Europe"
  account_type        = "Standard_LRS"

  tags {
    environment = "Testeabacao"
  }
}

# Create a virtual network in the associated with our resource group
resource "azurerm_virtual_network" "abacao-network" {
  name                = "abacao-network"
  address_space       = ["10.10.0.0/16"]
  location            = "North Europe"
  resource_group_name = "${azurerm_resource_group.abacao-rg.name}"

  tags {
    environment = "Testeabacao"
  }
}

# Create a subnet associated with our resource group and network
resource "azurerm_subnet" "abacao-subnet" {
  name                 = "abacao-sub"
  resource_group_name  = "${azurerm_resource_group.abacao-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.abacao-network.name}"
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_network_security_group" "abacao-nsg" {
  name                = "abacao-nsg"
  location            = "North Europe"
  resource_group_name = "${azurerm_resource_group.abacao-rg.name}"

  security_rule {
    name                       = "abacao-SecGrp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "89.115.236.13/32"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Testeabacao"
  }
}

resource "azurerm_network_interface" "abacao-nic" {
  name                = "abacao-NIC"
  location            = "North Europe"
  resource_group_name = "${azurerm_resource_group.abacao-rg.name}"

  #network_security_group_id = "${azurerm_network_security_group.abacao-nsg.id}"

  ip_configuration {
    name                          = "abacao_ip"
    subnet_id                     = "${azurerm_subnet.abacao-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.abacao-pub-ip.id}"
  }
  tags {
    environment = "Testeabacao"
  }
}

resource "azurerm_storage_container" "abacao-sc" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.abacao-rg.name}"
  storage_account_name  = "${azurerm_storage_account.abacaoStorageAccount.name}"
  container_access_type = "private"
}

resource "azurerm_public_ip" "abacao-pub-ip" {
  name                         = "abacao-pub-ip"
  location                     = "North Europe"
  resource_group_name          = "${azurerm_resource_group.abacao-rg.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Testeabacao"
  }
}

resource "azurerm_virtual_machine" "abacao-vm" {
  name                  = "abacao-ubuntuvm"
  location              = "North Europe"
  resource_group_name   = "${azurerm_resource_group.abacao-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.abacao-nic.id}"]
  vm_size               = "Basic_A1"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.abacaoStorageAccount.primary_blob_endpoint}${azurerm_storage_container.abacao-sc.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "ubuntubox"
    admin_username = "randomadmin"
    admin_password = "randompass1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    #     ssh_keys {
    #   path     = "/home/myadmin/.ssh/authorized_keys"
    #   key_data = "${file("~/.ssh/demo_key.pub")}"
    # }
  }

  tags {
    environment = "abacao-ubuntuvm"
  }
}
