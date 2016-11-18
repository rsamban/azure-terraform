#configure the micorsoft azure provider

provider "azurerm" {
  subscription_id = "${var.subscriptionid}"
  client_id       = "${var.clientid}"
  client_secret   = "${var.clientsecret}"
  tenant_id       = "${var.tenantid}"
}

# Create a resource group
resource "azurerm_resource_group" "pcfrg" {
  name     = "pcfrg"
  location = "West US"
}


resource "azurerm_public_ip" "firstPublicIP" {
  name                         = "firstPublicIP"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.pcfrg.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Test"
  }
}
resource "azurerm_public_ip" "secondPublicIP" {
  name                         = "secondPublicIP"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.pcfrg.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Test"
  }
}

resource "azurerm_public_ip" "thirdPublicIP" {
  name                         = "thirdPublicIP"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.pcfrg.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Test"
  }
}

resource "azurerm_public_ip" "jumpboxip" {
  name                         = "jumpboxip"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.pcfrg.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Test"
  }
}


resource "azurerm_virtual_network" "pcfnetwork" {
  name                = "pcfnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.pcfrg.name}"
}

resource "azurerm_subnet" "pcfsubnet" {
  name                 = "pcfsubnet"
  resource_group_name  = "${azurerm_resource_group.pcfrg.name}"
  virtual_network_name = "${azurerm_virtual_network.pcfnetwork.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_security_group" "pcfnsg" {
    name = "pcfnsg"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.pcfrg.name}"

    security_rule {
        name = "pcfnsgsr"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "TCP"
        source_port_range = "3389"
        destination_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Test"
    }
}

resource "azurerm_network_interface" "pcfni" {
  name                = "pcfni"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.pcfrg.name}"
  network_security_group_id = "${azurerm_network_security_group.pcfnsg.id}"

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = "${azurerm_subnet.pcfsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id  	  = "${azurerm_public_ip.jumpboxip.id}"
  }
}

resource "azurerm_storage_account" "pcfsa" {
  name                = "pcfsa"
  resource_group_name = "${azurerm_resource_group.pcfrg.name}"
  location            = "westus"
  account_type        = "Standard_LRS"

  tags {
    environment = "Test"
  }
}

resource "azurerm_storage_container" "pcfsc" {
  name                  = "pcfsc"
  resource_group_name   = "${azurerm_resource_group.pcfrg.name}"
  storage_account_name  = "${azurerm_storage_account.pcfsa.name}"
  container_access_type = "private"
}


resource "azurerm_virtual_machine" "pcfjumpbox" {
  name                  = "pcfjumpbox"
  location              = "West US"
  resource_group_name   = "${azurerm_resource_group.pcfrg.name}"
  network_interface_ids = ["${azurerm_network_interface.pcfni.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.pcfsa.primary_blob_endpoint}${azurerm_storage_container.pcfsc.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk0"
    vhd_uri       = "${azurerm_storage_account.pcfsa.primary_blob_endpoint}${azurerm_storage_container.pcfsc.name}/datadisk0.vhd"
    disk_size_gb  = "1023"
    create_option = "empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "pcfjumbox"
    admin_username = "pcfjumpbox"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}