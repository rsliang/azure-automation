variable "resourcename" {
  default = "myResourceGroup"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "327ead23-9a0f-4d49-a37f-9c9dda2818d4"
    client_id       = "d975d799-1355-4d24-9396-717a99856d4d"
    client_secret   = "b6bf0764-5734-44f9-87d1-c083218de09f"
    tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraform" {
    name     = "myResourceGroup"
    location = "East US"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "East US"
    resource_group_name = "${azurerm_resource_group.myterraform.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraform.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "East US"
    resource_group_name          = "${azurerm_resource_group.myterraform.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "East US"
    resource_group_name = "${azurerm_resource_group.myterraform.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "East US"
    resource_group_name       = "${azurerm_resource_group.myterraform.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraform.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.myterraform.name}"
    location            = "East US"
    #account_type        = "Standard_LRS"
    account_tier             = "Standard"
    account_replication_type = "LRS"


    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "East US"
    resource_group_name   = "${azurerm_resource_group.myterraform.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_A0"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZGc8x5Mxwb1BZwrMmBAML/V2kukHOsFPEf8RUhjFhlrAbump5r36HTcHtjR4jOCbJGi4pafqSZNkbyzuuGVEegKgTih8eT82bA7kAX+EUdk/ftUN0GMTVyaWOhizEj5IB4mfy5THn1AUXhhkNMc8uQVeyFP/WT71BufnJXT1clnqGdKrcKxg4/wIz8HZnqgPKXVfgefIR56PLGsepsebVSzFylauBxHPfX3APDPDH9dq2Kr61P9TLn0EKyM8fvFQ0Tc41LaQZbnvc2araIOuuFcXpc6XZ+PNjAMk0BuuVciTXgUvxY9fh6ZCLakUp8riDgVU3v8cZujBsvI+3V1CR"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}