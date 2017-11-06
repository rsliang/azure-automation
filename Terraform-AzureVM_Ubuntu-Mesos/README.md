This is a Terraform sample demo lab to create a complete Linux virtual machine and other related resources in Azure with Terraform, which includes the following ARM resources:

    - Azure connection 
    
    - Resource group
    
    - Virtual network
    
    - Public IP address
    
    - Network Security Group
    
    - Virtual network interface card
    
    - Storage account for diagnostics
    
    - Virtual machine

The "azurerm_virtual_machine" Azure provider for Terraform is used to express infrastructure-as-code, and to deploy Azure Virtual Machine instance and other related ARM resources.  In this demo lab, Terraform Microsoft AzureRM Provider will interact with the Azure Resource Manager resources via the AzureRM API's. Prior to any Azure resource deployment, the Azure provider for Terraform needs to be configured with the credentials needed to generate OAuth tokens for the AzureRM API's.

Terraform allows you to define and create complete infrastructure deployments in Azure. You build Terraform templates in a human-readable format that create and configure Azure resources in a consistent, reproducible manner. This demo lab shows you how to create a complete Linux environment and supporting resources with Terraform.

For more details, please see the "Install and configure Terraform to provision VMs and other infrastructure into Azure" Microsoft Docs link below:

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure


Part I. Install Terraform
*************************
Step (1): Download and unzip Terraform zip archive package for Windows, Linux or Mac

    https://www.terraform.io/downloads.html

Step (2): Add Terraform executable to the Path

    Make sure terraform binary is available on the PATH.

Step (3): Verify Terraform install and patth configuration

    $ terraform.exe

    Usage: terraform [--version] [--help] <command> [args]

Output:

    C:\opt\terraform_0.10.7_windows_amd64>terraform.exe

    Usage: terraform [--version] [--help] <command> [args]

    The available commands for execution are listed below.

    The most common, useful commands are shown first, followed by less common or more advanced commands. If you're just getting
    started with Terraform, stick with the common commands. For the other commands, please read the help and docs before usage.

    Common commands:

        apply              Builds or changes infrastructure

        console            Interactive console for Terraform interpolations

        destroy            Destroy Terraform-managed infrastructure

        env                Workspace management

        fmt                Rewrites config files to canonical format

        get                Download and install modules for the configuration

        graph              Create a visual graph of Terraform resources

        import             Import existing infrastructure into Terraform

        init               Initialize a Terraform working directory

        output             Read an output from a state file

        plan               Generate and show an execution plan

        providers          Prints a tree of the providers used in the configuration

        push               Upload this Terraform module to Atlas to run

        refresh            Update local state file against real resources

        show               Inspect Terraform state or plan

        taint              Manually mark a resource for recreation

        untaint            Manually unmark a resource as tainted

        validate           Validates the Terraform files

        version            Prints the Terraform version

        workspace          Workspace management

    All other commands:

        debug              Debug output management (experimental)

        force-unlock       Manually unlock the terraform state

        state              Advanced state management

    Usage: terraform [--version] [--help] <command> [args]

    The available commands for execution are listed below.

    The most common, useful commands are shown first, followed by less common or more advanced commands. If you're just getting
    started with Terraform, stick with the common commands. For the other commands, please read the help and docs before usage.

Step (4): Set up Terraform access to Azure

To enable Terraform to provision resources into Azure, you need to create two entities in Azure Active Directory (Azure AD): an Azure AD application and an Azure AD service principal.  The service principal grants your Terraform scripts using credentials to provision resources in your Azure subscription.

Azure env setup: provider.azurerm

Run `az login` to obtain Azure CLI Auth Tokens 

    $ az login

Output:

    C:\>az login

    To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code EJGA3L6Q7 to authenticate.

        4.1) Go to browser and navigate to: https://aka.ms/devicelogin
        4.2) Azure authentication with Device Login code: EJGA3L6Q7

        4.3) Click <Continue> > to select azure account to login
        4.4) Azure CLI - Azure authenticated

        4.5) Go back to CLI - Completed authentication with Azure
        [
          {
            "cloudName": "AzureCloud",
            "id": "c27{...}c1c",
            "isDefault": true,
            "name": "{...}",
            "state": "Enabled",
            "tenantId": "bf5{...}9d3",
            "user": {
              "name": "{...}@{...}.com",
              "type": "user"
            }
          }
        ]

Step (6): (Optional) Set subscription ID for the sesssion

Set the SUBSCRIPTION_ID environment variable to hold the value of the returned id field from the subscription you want to use if you have multiple Azure subscriptions.

    $ az account set --subscription="${SUBSCRIPTION_ID}"

Output:

    C:\>az account set --subscription="c27{...}c1c"


Step (6): Query account for subscription ID and tenant ID:

    $ az account show --query "{subscriptionId:id, tenantId:tenantId}"

Output:

    C:\>az account show --query "{subscriptionId:id, tenantId:tenantId}"
    {
      "subscriptionId": "c27{...}c1c",
      "tenantId": "bf5{...}9d3"
    }

Step (7): Create separate credential for Terraform

    $ az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

Output:

    C:\>az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/c27{...}c1c"

    {
      "appId": "{...}b82",
      "displayName": "azure-cli-{...}",
      "name": "http://azure-cli-{...}",
      "password": "b65{...}be1",
      "tenant": "bf5{...}9d3"
    }

Step (8): Set environment variables (optional)

After you create and configure an Azure AD service principal, you need to let Terraform know the tenant ID, subscription ID, client ID, and client secret to use. You can do it by embedding those values in your Terraform scripts, as described in Create basic infrastructure by using Terraform. Alternately, you can set the following environment variables (and thus avoid accidentally checking in or sharing your credentials):+

    ARM_SUBSCRIPTION_ID

    ARM_CLIENT_ID

    ARM_CLIENT_SECRET

    ARM_TENANT_ID

Sample shell script to set those variables:

    #!/bin/sh

    echo "Setting environment variables for Terraform"

    export ARM_SUBSCRIPTION_ID=your_subscription_id

    export ARM_CLIENT_ID=your_appId

    export ARM_CLIENT_SECRET=your_password

    export ARM_TENANT_ID=your_tenant_id

Step (9): Create a tf script to be used directly by Terrform to deploy a complete Azure VM and other related sources.

Creates an Azure Ubuntu Linux Virtual Machine Instance

Note: All arguments including the client secret will be stored in the raw state as plain-text. Read more about sensitive data in state.

Terraform Provider: azurerm_virtual_machine 

Copy and paster the followig content into the Create-VM-StdA0.tf JSON file:

    variable "resourcename" {
      default = "myResourceGroup"
    }

    # Configure the Microsoft Azure Provider
    provider "azurerm" {
        subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        tenant_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }

    # Create a resource group if it doesn’t exist
    resource "azurerm_resource_group" "myterraformgroup" {
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
        resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

        tags {
            environment = "Terraform Demo"
        }
    }

    # Create subnet
    resource "azurerm_subnet" "myterraformsubnet" {
        name                 = "mySubnet"
        resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
        virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
        address_prefix       = "10.0.1.0/24"
    }

    # Create public IPs
    resource "azurerm_public_ip" "myterraformpublicip" {
        name                         = "myPublicIP"
        location                     = "East US"
        resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
        public_ip_address_allocation = "dynamic"

        tags {
            environment = "Terraform Demo"
        }
    }

    # Create Network Security Group and rule
    resource "azurerm_network_security_group" "myterraformnsg" {
        name                = "myNetworkSecurityGroup"
        location            = "East US"
        resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

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
        resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
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
            resource_group = "${azurerm_resource_group.myterraformgroup.name}"
        }

        byte_length = 8
    }

    # Create storage account for boot diagnostics
    resource "azurerm_storage_account" "mystorageaccount" {
        name                = "diag${random_id.randomId.hex}"
        resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
        location            = "East US"
        account_type        = "Standard_LRS"

        tags {
            environment = "Terraform Demo"
        }
    }

    # Create virtual machine
    resource "azurerm_virtual_machine" "myterraformvm" {
        name                  = "myVM"
        location              = "East US"
        resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
        network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
        vm_size               = "Standard_DS1_v2"

        storage_os_disk {
            name              = "myOsDisk"
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Premium_LRS"
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
                key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
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



**************************************************************************
Part II. Create a complete Azure VM - run the sample demo Terraform script
**************************************************************************
Create a complete VM with Ubuntu Linux OS and other related resources.

step (1): Initialize Terraform. 

This step ensures that Terraform has all the prerequisites to build your template in Azure.

Terraform configuration file: Create-VM-StdA0.tf

Set Size=Standard A0

Set OSDisk=Standard LRS

    $ terraform init

Output:
    C:\>terraform init

    Initializing provider plugins...
    - Checking for available provider plugins on https://releases.hashicorp.com...
    - Downloading plugin for provider "random" (1.0.0)...
    - Downloading plugin for provider "azurerm" (0.3.0)...

    The following providers do not have any version constraints in configuration,
    so the latest version was installed.

    To prevent automatic upgrades to new major versions that may contain breaking
    changes, it is recommended to add version = "..." constraints to the
    corresponding provider blocks in configuration, with the constraint strings
    suggested below.

    * provider.azurerm: version = "~> 0.3"
    * provider.random: version = "~> 1.0"

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.


step (2): Terraform review and validate the template. 

This step compares the requested resources to the state information saved by Terraform and then outputs the planned execution. Resources are not created in Azure.

    $ terraform plan

Output:
    C:\>terraform plan

    There are warnings related to your configuration. If no errors occurred, Terraform will continue despite these warnings. It is a good idea to resolve these warnings in the near future.

    Warnings:

      * azurerm_storage_account.mystorageaccount: "account_type": [DEPRECATED] This field has been split into `account_tier` and `account_replication_type`

    2 error(s) occurred:

    * azurerm_storage_account.mystorageaccount: "account_replication_type": required field is not set

    * azurerm_storage_account.mystorageaccount: "account_tier": required field is not set

Step (3): Terraform Plan

    $ terraform plan

Output:
    $ C:\>terraform plan
    Refreshing Terraform state in-memory prior to plan...
    The refreshed state will be used to calculate this plan, but will not be
    persisted to local or remote state storage.
    ------------------------------------------------------------------------
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create
    Terraform will perform the following actions:
      + azurerm_network_interface.myterraformnic
          id:                                                               <computed>
          applied_dns_servers.#:                                            <computed>
          dns_servers.#:                                                    <computed>
          enable_ip_forwarding:                                             "false"
          internal_dns_name_label:                                          <computed>
          internal_fqdn:                                                    <computed>
          ip_configuration.#:                                               "1"
          ip_configuration.0.load_balancer_backend_address_pools_ids.#:     <computed>
          ip_configuration.0.load_balancer_inbound_nat_rules_ids.#:         <computed>
          ip_configuration.0.name:                                          "myNicConfiguration"
          ip_configuration.0.primary:                                       <computed>
          ip_configuration.0.private_ip_address:                            <computed>
          ip_configuration.0.private_ip_address_allocation:                 "dynamic"
          ip_configuration.0.public_ip_address_id:                          "${azurerm_public_ip.myterraformpublicip.id}"
          ip_configuration.0.subnet_id:                                     "${azurerm_subnet.myterraformsubnet.id}"
          location:                                                         "eastus"
          mac_address:                                                      <computed>
          name:                                                             "myNIC"
          network_security_group_id:                                        "${azurerm_network_security_group.myterraformnsg.id}"
          private_ip_address:                                               <computed>
          private_ip_addresses.#:                                           <computed>
          resource_group_name:                                              "myResourceGroup"
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
          virtual_machine_id:                                               <computed>
      + azurerm_network_security_group.myterraformnsg
          id:                                                               <computed>
          location:                                                         "eastus"
          name:                                                             "myNetworkSecurityGroup"
          resource_group_name:                                              "myResourceGroup"
          security_rule.#:                                                  "1"
          security_rule.0.access:                                           "Allow"
          security_rule.0.destination_address_prefix:                       "*"
          security_rule.0.destination_port_range:                           "22"
          security_rule.0.direction:                                        "Inbound"
          security_rule.0.name:                                             "SSH"
          security_rule.0.priority:                                         "1001"
          security_rule.0.protocol:                                         "tcp"
          security_rule.0.source_address_prefix:                            "*"
          security_rule.0.source_port_range:                                "*"
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
      + azurerm_public_ip.myterraformpublicip
          id:                                                               <computed>
          fqdn:                                                             <computed>
          ip_address:                                                       <computed>
          location:                                                         "eastus"
          name:                                                             "myPublicIP"
          public_ip_address_allocation:                                     "dynamic"
          resource_group_name:                                              "myResourceGroup"
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
      + azurerm_resource_group.myterraform
          id:                                                               <computed>
          location:                                                         "eastus"
          name:                                                             "myResourceGroup"
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
      + azurerm_storage_account.mystorageaccount
          id:                                                               <computed>
          access_tier:                                                      <computed>
          account_encryption_source:                                        "Microsoft.Storage"
          account_kind:                                                     "Storage"
          account_replication_type:                                         "LRS"
          account_tier:                                                     "Standard"
          enable_blob_encryption:                                           <computed>
          enable_file_encryption:                                           <computed>
          location:                                                         "eastus"
          name:                                                             "diag${random_id.randomId.hex}"
          primary_access_key:                                               <computed>
          primary_blob_connection_string:                                   <computed>
          primary_blob_endpoint:                                            <computed>
          primary_file_endpoint:                                            <computed>
          primary_location:                                                 <computed>
          primary_queue_endpoint:                                           <computed>
          primary_table_endpoint:                                           <computed>
          resource_group_name:                                              "myResourceGroup"
          secondary_access_key:                                             <computed>
          secondary_blob_connection_string:                                 <computed>
          secondary_blob_endpoint:                                          <computed>
          secondary_location:                                               <computed>
          secondary_queue_endpoint:                                         <computed>
          secondary_table_endpoint:                                         <computed>
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
      + azurerm_subnet.myterraformsubnet
          id:                                                               <computed>
          address_prefix:                                                   "10.0.1.0/24"
          ip_configurations.#:                                              <computed>
          name:                                                             "mySubnet"
          resource_group_name:                                              "myResourceGroup"
          virtual_network_name:                                             "myVnet"
      + azurerm_virtual_machine.myterraformvm
          id:                                                               <computed>
          availability_set_id:                                              <computed>
          boot_diagnostics.#:                                               "1"
          boot_diagnostics.0.enabled:                                       "true"
          boot_diagnostics.0.storage_uri:                                   "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
          delete_data_disks_on_termination:                                 "false"
          delete_os_disk_on_termination:                                    "false"
          location:                                                         "eastus"
          name:                                                             "myVM"
          network_interface_ids.#:                                          <computed>
          os_profile.#:                                                     "1"
          os_profile.1770182618.admin_password:                             <sensitive>
          os_profile.1770182618.admin_username:                             "azureuser"
          os_profile.1770182618.computer_name:                              "myvm"
          os_profile.1770182618.custom_data:                                <computed>
          os_profile_linux_config.#:                                        "1"
          os_profile_linux_config.69840937.disable_password_authentication: "true"
          os_profile_linux_config.69840937.ssh_keys.#:                      "1"
          os_profile_linux_config.69840937.ssh_keys.0.key_data:             "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
          os_profile_linux_config.69840937.ssh_keys.0.path:                 "/home/azureuser/.ssh/authorized_keys"
          resource_group_name:                                              "myResourceGroup"
          storage_image_reference.#:                                        "1"
          storage_image_reference.363552096.id:                             ""
          storage_image_reference.363552096.offer:                          "UbuntuServer"
          storage_image_reference.363552096.publisher:                      "Canonical"
          storage_image_reference.363552096.sku:                            "16.04.0-LTS"
          storage_image_reference.363552096.version:                        "latest"
          storage_os_disk.#:                                                "1"
          storage_os_disk.0.caching:                                        "ReadWrite"
          storage_os_disk.0.create_option:                                  "FromImage"
          storage_os_disk.0.disk_size_gb:                                   <computed>
          storage_os_disk.0.managed_disk_id:                                <computed>
          storage_os_disk.0.managed_disk_type:                              "Standard_LRS"
          storage_os_disk.0.name:                                           "myOsDisk"
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
          vm_size:                                                          "Standard_A0"
      + azurerm_virtual_network.myterraformnetwork
          id:                                                               <computed>
          address_space.#:                                                  "1"
          address_space.0:                                                  "10.0.0.0/16"
          location:                                                         "eastus"
          name:                                                             "myVnet"
          resource_group_name:                                              "myResourceGroup"
          subnet.#:                                                         <computed>
          tags.%:                                                           "1"
          tags.environment:                                                 "Terraform Demo"
      + random_id.randomId
          id:                                                               <computed>
          b64:                                                              <computed>
          b64_std:                                                          <computed>
          b64_url:                                                          <computed>
          byte_length:                                                      "8"
          dec:                                                              <computed>
          hex:                                                              <computed>
          keepers.%:                                                        "1"
          keepers.resource_group:                                           "myResourceGroup"
    Plan: 9 to add, 0 to change, 0 to destroy.
    ------------------------------------------------------------------------
    Note: You didn't specify an "-out" parameter to save this plan, so Terraform
    can't guarantee that exactly these actions will be performed if
    "terraform apply" is subsequently run.

Step (4): Build the complete Azure VM infrastructure in Azure, apply the template in Terraform

    $ terraform apply

Output:
    C:\>terraform apply
    azurerm_resource_group.myterraform: Refreshing state... (ID: /subscriptions/327{...}a2818d4/resourceGroups/myResourceGroup)
    azurerm_network_security_group.myterraformnsg: Refreshing state... (ID: /subscriptions/327...}kSecurityGroups/myNetworkSecurityGroup)
    random_id.randomId: Refreshing state... (ID: sZ0MVYFToy4)
    azurerm_virtual_network.myterraformnetwork: Refreshing state... (ID: /subscriptions/327{...}crosoft.Network/virtualNetworks/myVnet)
    azurerm_public_ip.myterraformpublicip: Refreshing state... (ID: /subscriptions/327{...}t.Network/publicIPAddresses/myPublicIP)
    azurerm_storage_account.mystorageaccount: Refreshing state... (ID: /subscriptions/327...}e/storageAccounts/diagb19d0c558153a32e)
    azurerm_subnet.myterraformsubnet: Refreshing state... (ID: /subscriptions/327{...}irtualNetworks/myVnet/subnets/mySubnet)
    azurerm_network_interface.myterraformnic: Refreshing state... (ID: /subscriptions/327{...}rosoft.Network/networkInterfaces/myNIC)
    azurerm_virtual_machine.myterraformvm: Creating...
      availability_set_id:                                              "" => "<computed>"
      boot_diagnostics.#:                                               "" => "1"
      boot_diagnostics.0.enabled:                                       "" => "true"
      boot_diagnostics.0.storage_uri:                                   "" => "https://diagb19d0c558153a32e.blob.core.windows.net/"
      delete_data_disks_on_termination:                                 "" => "false"
      delete_os_disk_on_termination:                                    "" => "false"
      location:                                                         "" => "eastus"
      name:                                                             "" => "myVM"
      network_interface_ids.#:                                          "" => "1"
      network_interface_ids.0:                                          "" => "/subscriptions/327{...}8d4/resourceGroups/myResourceGroup/providers/Microsoft.Network/networkInterfaces/myNIC"
      os_profile.#:                                                     "" => "1"
      os_profile.1770182618.admin_password:                             "<sensitive>" => "<sensitive>"
      os_profile.1770182618.admin_username:                             "" => "{...}"
      os_profile.1770182618.computer_name:                              "" => "myvm"
      os_profile.1770182618.custom_data:                                "" => "<computed>"
      os_profile_linux_config.#:                                        "" => "1"
      os_profile_linux_config.69840937.disable_password_authentication: "" => "true"
      os_profile_linux_config.69840937.ssh_keys.#:                      "" => "1"
      os_profile_linux_config.69840937.ssh_keys.0.key_data:             "" => "ssh-rsa AAA{...}1CR"
      os_profile_linux_config.69840937.ssh_keys.0.path:                 "" => "/home/azureuser/.ssh/authorized_keys"
      resource_group_name:                                              "" => "myResourceGroup"
      storage_image_reference.#:                                        "" => "1"
      storage_image_reference.363552096.id:                             "" => ""
      storage_image_reference.363552096.offer:                          "" => "UbuntuServer"
      storage_image_reference.363552096.publisher:                      "" => "Canonical"
      storage_image_reference.363552096.sku:                            "" => "16.04.0-LTS"
      storage_image_reference.363552096.version:                        "" => "latest"
      storage_os_disk.#:                                                "" => "1"
      storage_os_disk.0.caching:                                        "" => "ReadWrite"
      storage_os_disk.0.create_option:                                  "" => "FromImage"
      storage_os_disk.0.disk_size_gb:                                   "" => "<computed>"
      storage_os_disk.0.managed_disk_id:                                "" => "<computed>"
      storage_os_disk.0.managed_disk_type:                              "" => "Standard_LRS"
      storage_os_disk.0.name:                                           "" => "myOsDisk"
      tags.%:                                                           "" => "1"
      tags.environment:                                                 "" => "Terraform Demo"
      vm_size:                                                          "" => "Standard_A0"
    azurerm_virtual_machine.myterraformvm: Still creating... (10s elapsed)
    ...
    azurerm_virtual_machine.myterraformvm: Still creating... (3m0s elapsed)
    azurerm_virtual_machine.myterraformvm: Creation complete after 3m1s (ID: /subscriptions/327ead23-9a0f-4d49-a37f-...Microsoft.Compute/virtualMachines/myVM)

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    > Azure Portal: List of myResourceGroup VM & associated resources created from running "terraform apply"
 


Step (5): Obtain the public IP address of your VM with az vm show

    $ az vm show --resource-group myResourceGroup --name myVM -d --query [publicIps] --o tsv

Output:
    C:\>az vm show --resource-group myResourceGroup --name myVM -d --query [publicIps] --o tsv

    52.179.14.5


Step (6): SSH into the VM using Git Bash CLI to install Mesos on Ubuntu

    $ ssh azureuser@<publicIps>

Output (Git Bash CLI):
    {snip}@{snip} MINGW64 /c/demo/Terraform
    $ ssh azureuser@52.{...}.14.5
    The authenticity of host '52.{...}.5 (52.{...}.14.5)' can't be established.
    ECDSA key fingerprint is SHA256:zmlIsQ85hs8HTOe2hT39Tu7Dw0oYQWF8zyhfYRci6Fg.
    Are you sure you want to continue connecting (yes/no)? y
    Please type 'yes' or 'no': yes
    Warning: Permanently added '52.{...}.5' (ECDSA) to the list of known hosts.
    Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-47-generic x86_64)

     * Documentation:  https://help.ubuntu.com
     * Management:     https://landscape.canonical.com
     * Support:        https://ubuntu.com/advantage

      Get cloud support with Ubuntu Advantage Cloud Guest:
        http://www.ubuntu.com/business/services/cloud

    0 packages can be updated.
    0 updates are security updates.

    The programs included with the Ubuntu system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
    applicable law.

    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.

    azureuser@myvm:~$


Part III. Install Mesos on Linux Ubuntu 16.04:

Step (1): Downloading Mesos

Download latest stable Mesos release from Apache and extract tar file

    $ wget http://www.apache.org/dist/mesos/1.4.0/mesos-1.4.0.tar.gz
    $ tar -zxf mesos-1.4.0.tar.gz

Output (Git Bash CLI):
    azureuser@myvm:~$ wget http://www.apache.org/dist/mesos/1.4.0/mesos-1.4.0.tar.gz
    --2017-10-19 03:52:59--  http://www.apache.org/dist/mesos/1.4.0/mesos-1.4.0.tar.gz
    Resolving www.apache.org (www.apache.org)... 140.211.11.105
    Connecting to www.apache.org (www.apache.org)|140.211.11.105|:80... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 53891113 (51M) [application/x-gzip]
    Saving to: ‘mesos-1.4.0.tar.gz’

    mesos-1.4.0.tar.gz          100%[===========================================>]  51.39M  20.6MB/s    in 2.5s

    2017-10-19 03:53:02 (20.6 MB/s) - ‘mesos-1.4.0.tar.gz’ saved [53891113/53891113]

    azureuser@myvm:~$ tar -zxf mesos-1.4.0.tar.gz
    azureuser@myvm:~$ ls
    mesos-1.4.0  mesos-1.4.0.tar.gz

Step (2): Clone the Mesos git repository

    $ git clone https://git-wip-us.apache.org/repos/asf/mesos.git

Output (Git Bash CLI):
    azureuser@myvm:~$ git clone https://git-wip-us.apache.org/repos/asf/mesos.git
    Cloning into 'mesos'...
    remote: Counting objects: 129874, done.
    remote: Compressing objects: 100% (31185/31185), done.
    remote: Total 129874 (delta 100330), reused 123104 (delta 95034)
    Receiving objects: 100% (129874/129874), 286.86 MiB | 7.87 MiB/s, done.
    Resolving deltas: 100% (100330/100330), done.
    Checking connectivity... done.
    Checking out files: 100% (1946/1946), done.
    azureuser@myvm:~$
    azureuser@myvm:~$ ls
    mesos  mesos-1.4.0  mesos-1.4.0.tar.gz


    System Requirements - Ubuntu 16.04

Step (3): Update the packages.

    $ sudo apt-get update

Output (Git Bash CLI):
    azureuser@myvm:~$ sudo apt-get update
    Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [102 kB]
    Hit:2 http://azure.archive.ubuntu.com/ubuntu xenial InRelease
    Get:3 http://azure.archive.ubuntu.com/ubuntu xenial-updates InRelease [102 kB]
    Get:4 http://azure.archive.ubuntu.com/ubuntu xenial-backports InRelease [102 kB]
    Get:5 <http://security.ubuntu.com/ubuntu xenial-security/main> Sources [97.9 kB]
    Get:6 <http://security.ubuntu.com/ubuntu xenial-security/restricted> Sources [2,600 B]
    Get:7 <http://security.ubuntu.com/ubuntu xenial-security/universe> Sources [43.4 kB]
    Get:8 <http://security.ubuntu.com/ubuntu xenial-security/multiverse> Sources [1,140 B]
    Get:9 <http://security.ubuntu.com/ubuntu xenial-security/main> amd64 Packages [370 kB]
    Get:10 <http://security.ubuntu.com/ubuntu xenial-security/main> Translation-en [164 kB]
    Get:11 <http://security.ubuntu.com/ubuntu xenial-security/restricted> amd64 Packages [7,352 B]
    Get:12 <http://security.ubuntu.com/ubuntu xenial-security/restricted> Translation-en [2,432 B]
    Get:13 <http://security.ubuntu.com/ubuntu xenial-security/universe> amd64 Packages [175 kB]
    Get:14 <http://security.ubuntu.com/ubuntu xenial-security/universe> Translation-en [93.0 kB]
    Get:15 <http://security.ubuntu.com/ubuntu xenial-security/multiverse> amd64 Packages [2,756 B]
    Get:16 <http://security.ubuntu.com/ubuntu xenial-security/multiverse> Translation-en [1,236 B]
    Get:17 <http://azure.archive.ubuntu.com/ubuntu xenial/main> Sources [868 kB]
    Get:18 <http://azure.archive.ubuntu.com/ubuntu xenial/restricted> Sources [4,808 B]
    Get:19 <http://azure.archive.ubuntu.com/ubuntu xenial/universe> Sources [7,728 kB]
    Get:20 <http://azure.archive.ubuntu.com/ubuntu xenial/multiverse> Sources [179 kB]
    Get:21 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> Sources [278 kB]
    Get:22 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/restricted> Sources [3,404 B]
    Get:23 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/universe> Sources [176 kB]
    Get:24 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/multiverse> Sources [7,208 B]
    Get:25 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 Packages [642 kB]
    Get:26 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> Translation-en [269 kB]
    Get:27 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/restricted> amd64 Packages [7,972 B]
    Get:28 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/restricted> Translation-en [2,692 B]
    Get:29 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/universe> amd64 Packages [540 kB]
    Get:30 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/universe> Translation-en [220 kB]
    Get:31 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/multiverse> amd64 Packages [15.3 kB]
    Get:32 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/multiverse> Translation-en [7,544 B]
    Get:33 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/main> Sources [3,432 B]
    Get:34 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/universe> Sources [4,376 B]
    Get:35 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/main> amd64 Packages [4,860 B]
    Get:36 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/main> Translation-en [3,220 B]
    Get:37 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/universe> amd64 Packages [5,896 B]
    Get:38 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/universe> Translation-en [3,060 B]
    Fetched 12.2 MB in 9s (1,330 kB/s)
    Reading package lists... Done
    azureuser@myvm:~$

Step (4): Install a few utility tools.

    $ sudo apt-get install -y tar wget git

Output (Git Bash CLI):
    azureuser@myvm:~$ sudo apt-get install -y tar wget git
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    Suggested packages:
      git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-arch git-cvs
      git-mediawiki git-svn ncompress tar-scripts
    The following packages will be upgraded:
      git tar wget
    3 upgraded, 0 newly installed, 0 to remove and 201 not upgraded.
    Need to get 3,609 kB of archives.
    After this operation, 24.6 kB of additional disk space will be used.
    Get:1 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 tar amd64 1.28-2.1ubuntu0.1 [209 kB]
    Get:2 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 wget amd64 1.17.1-1ubuntu1.2 [298 kB]
    Get:3 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 git amd64 1:2.7.4-0ubuntu1.3 [3,102 kB]
    Fetched 3,609 kB in 0s (4,096 kB/s)
    (Reading database ... 61252 files and directories currently installed.)
    Preparing to unpack .../tar_1.28-2.1ubuntu0.1_amd64.deb ...
    Unpacking tar (1.28-2.1ubuntu0.1) over (1.28-2.1) ...
    Processing triggers for man-db (2.7.5-1) ...
    Processing triggers for mime-support (3.59ubuntu1) ...
    Setting up tar (1.28-2.1ubuntu0.1) ...
    (Reading database ... 61252 files and directories currently installed.)
    Preparing to unpack .../wget_1.17.1-1ubuntu1.2_amd64.deb ...
    Unpacking wget (1.17.1-1ubuntu1.2) over (1.17.1-1ubuntu1.1) ...
    Preparing to unpack .../git_1%3a2.7.4-0ubuntu1.3_amd64.deb ...
    Unpacking git (1:2.7.4-0ubuntu1.3) over (1:2.7.4-0ubuntu1) ...
    Processing triggers for install-info (6.1.0.dfsg.1-5) ...
    Processing triggers for man-db (2.7.5-1) ...
    Setting up wget (1.17.1-1ubuntu1.2) ...
    Setting up git (1:2.7.4-0ubuntu1.3) ...
    azureuser@myvm:~$


step (5): Install the latest OpenJDK.

    $ sudo apt-get install -y openjdk-8-jdk

Output (Git Bash CLI):
    azureuser@myvm:~$ sudo apt-get install -y openjdk-8-jdk
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following additional packages will be installed:
      ca-certificates-java fontconfig fontconfig-config fonts-dejavu-core fonts-dejavu-extra hicolor-icon-theme
      java-common libasound2 libasound2-data libasyncns0 libatk1.0-0 libatk1.0-data libcairo2 libdatrie1
      libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libflac8 libfontconfig1 libgdk-pixbuf2.0-0
      libgdk-pixbuf2.0-common libgif7 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgraphite2-3 libgtk2.0-0
      libgtk2.0-bin libgtk2.0-common libharfbuzz0b libice-dev libice6 libjbig0 libjpeg-turbo8 libjpeg8 liblcms2-2
      libllvm4.0 libnspr4 libnss3 libnss3-nssdb libogg0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
      libpciaccess0 libpcsclite1 libpixman-1-0 libpthread-stubs0-dev libpulse0 libsensors4 libsm-dev libsm6
      libsndfile1 libthai-data libthai0 libtiff5 libtxc-dxtn-s2tc0 libvorbis0a libvorbisenc2 libx11-dev libx11-doc
      libx11-xcb1 libxau-dev libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-shm0
      libxcb-sync1 libxcb1-dev libxcomposite1 libxcursor1 libxdamage1 libxdmcp-dev libxfixes3 libxi6 libxinerama1
      libxrandr2 libxrender1 libxshmfence1 libxt-dev libxt6 libxtst6 libxxf86vm1 openjdk-8-jdk-headless
      openjdk-8-jre openjdk-8-jre-headless x11-common x11proto-core-dev x11proto-input-dev x11proto-kb-dev
      xorg-sgml-doctools xtrans-dev
    Suggested packages:
      default-jre libasound2-plugins alsa-utils librsvg2-common gvfs libice-doc liblcms2-utils pcscd pulseaudio
      lm-sensors libsm-doc libxcb-doc libxt-doc openjdk-8-demo openjdk-8-source visualvm icedtea-8-plugin
      openjdk-8-jre-jamvm libnss-mdns fonts-ipafont-gothic fonts-ipafont-mincho fonts-wqy-microhei
      fonts-wqy-zenhei fonts-indic
    The following NEW packages will be installed:
      ca-certificates-java fontconfig fontconfig-config fonts-dejavu-core fonts-dejavu-extra hicolor-icon-theme
      java-common libasound2 libasound2-data libasyncns0 libatk1.0-0 libatk1.0-data libcairo2 libdatrie1
      libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libflac8 libfontconfig1 libgdk-pixbuf2.0-0
      libgdk-pixbuf2.0-common libgif7 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgraphite2-3 libgtk2.0-0
      libgtk2.0-bin libgtk2.0-common libharfbuzz0b libice-dev libice6 libjbig0 libjpeg-turbo8 libjpeg8 liblcms2-2
      libllvm4.0 libnspr4 libnss3 libnss3-nssdb libogg0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
      libpciaccess0 libpcsclite1 libpixman-1-0 libpthread-stubs0-dev libpulse0 libsensors4 libsm-dev libsm6
      libsndfile1 libthai-data libthai0 libtiff5 libtxc-dxtn-s2tc0 libvorbis0a libvorbisenc2 libx11-dev libx11-doc
      libx11-xcb1 libxau-dev libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-shm0
      libxcb-sync1 libxcb1-dev libxcomposite1 libxcursor1 libxdamage1 libxdmcp-dev libxfixes3 libxi6 libxinerama1
      libxrandr2 libxrender1 libxshmfence1 libxt-dev libxt6 libxtst6 libxxf86vm1 openjdk-8-jdk
      openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless x11-common x11proto-core-dev x11proto-input-dev
      x11proto-kb-dev xorg-sgml-doctools xtrans-dev
    0 upgraded, 96 newly installed, 0 to remove and 201 not upgraded.
    Need to get 66.9 MB of archives.
    After this operation, 366 MB of additional disk space will be used.
    Get:1 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 fonts-dejavu-core all 2.35-1 [1,039 kB]
    Get:2 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 fontconfig-config all 2.11.94-0ubuntu1.1 [49.9 kB]
    Get:3 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libfontconfig1 amd64 2.11.94-0ubuntu1.1 [131 kB]
    Get:4 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 fontconfig amd64 2.11.94-0ubuntu1.1 [178 kB]
    Get:5 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libasyncns0 amd64 0.8-5build1 [12.3 kB]
    Get:6 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 x11-common all 1:7.7+13ubuntu3 [22.4 kB]
    Get:7 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libice6 amd64 2:1.0.9-1 [39.2 kB]
    Get:8 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libjpeg-turbo8 amd64 1.4.2-0ubuntu3 [111 kB]
    Get:9 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 liblcms2-2 amd64 2.6-3ubuntu2 [137 kB]

    .....

    Adding debian:RSA_Security_2048_v3.pem
    Adding debian:S-TRUST_Authentication_and_Encryption_Root_CA_2005_PN.pem
    Adding debian:Certum_Trusted_Network_CA.pem
    Adding debian:Buypass_Class_2_CA_1.pem
    Adding debian:NetLock_Arany_=Class_Gold=_Főtanúsítvány.pem
    Adding debian:TÜRKTRUST_Elektronik_Sertifika_Hizmet_Sağlayıcısı_H6.pem
    Adding debian:Buypass_Class_3_Root_CA.pem
    Adding debian:Equifax_Secure_Global_eBusiness_CA.pem
    done.
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    Processing triggers for systemd (229-4ubuntu12) ...
    Processing triggers for ureadahead (0.100.0-19) ...
    Processing triggers for ca-certificates (20160104ubuntu1) ...
    Updating certificates in /etc/ssl/certs...
    0 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...

    done.
    done.
    azureuser@myvm:~$

Step (6): Install autotools (Only necessary if building from git repository).

    $ sudo apt-get install -y autoconf libtool

Output (Git Bash CLI):
    azureuser@myvm:~$ sudo apt-get install -y autoconf libtool
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following additional packages will be installed:
      automake autotools-dev binutils cpp cpp-5 gcc gcc-5 gcc-5-base libasan2 libatomic1 libc-dev-bin libc6
      libc6-dev libcc1-0 libcilkrts5 libgcc-5-dev libgomp1 libisl15 libitm1 liblsan0 libltdl-dev libltdl7 libmpc3
      libmpx0 libquadmath0 libstdc++6 libtsan0 libubsan0 linux-libc-dev m4 manpages-dev
    Suggested packages:
      autoconf-archive gnu-standards autoconf-doc gettext binutils-doc cpp-doc gcc-5-locales gcc-multilib make
      flex bison gdb gcc-doc gcc-5-multilib gcc-5-doc libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg
      libasan2-dbg liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx0-dbg libquadmath0-dbg glibc-doc
      libtool-doc gfortran | fortran95-compiler gcj-jdk
    The following NEW packages will be installed:
      autoconf automake autotools-dev binutils cpp cpp-5 gcc gcc-5 libasan2 libatomic1 libc-dev-bin libc6-dev
      libcc1-0 libcilkrts5 libgcc-5-dev libgomp1 libisl15 libitm1 liblsan0 libltdl-dev libltdl7 libmpc3 libmpx0
      libquadmath0 libtool libtsan0 libubsan0 linux-libc-dev m4 manpages-dev
    The following packages will be upgraded:
      gcc-5-base libc6 libstdc++6
    3 upgraded, 30 newly installed, 0 to remove and 198 not upgraded.
    Need to get 32.1 MB of archives.
    After this operation, 106 MB of additional disk space will be used.
    Get:1 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libc6 amd64 2.23-0ubuntu9 [2,586 kB]
    Get:2 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libmpc3 amd64 1.0.3-1 [39.7 kB]
    Get:3 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 gcc-5-base amd64 5.4.0-6ubuntu1~16.04.5 [17.1 kB]
    Get:4 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libstdc++6 amd64 5.4.0-6ubuntu1~16.04.5 [393 kB]
    Get:5 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 m4 amd64 1.4.17-5 [195 kB]
    Get:6 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 autoconf all 2.69-9 [321 kB]
    Get:7 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 autotools-dev all 20150820.1 [39.8 kB]
    Get:8 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 automake all 1:1.15-4ubuntu1 [510 kB]
    Get:9 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 binutils amd64 2.26.1-1ubuntu1~16.04.5 [2,311 kB]
    Get:10 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libisl15 amd64 0.16.1-1 [524 kB]
    Get:11 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 cpp-5 amd64 5.4.0-6ubuntu1~16.04.5 [7,786 kB]
    Get:12 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 cpp amd64 4:5.3.1-1ubuntu1 [27.7 kB]
    Get:13 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libcc1-0 amd64 5.4.0-6ubuntu1~16.04.5 [38.8 kB]
    Get:14 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libgomp1 amd64 5.4.0-6ubuntu1~16.04.5 [55.1 kB]
    Get:15 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libitm1 amd64 5.4.0-6ubuntu1~16.04.5 [27.4 kB]
    Get:16 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libatomic1 amd64 5.4.0-6ubuntu1~16.04.5 [8,920 B]
    Get:17 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libasan2 amd64 5.4.0-6ubuntu1~16.04.5 [264 kB]
    Get:18 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 liblsan0 amd64 5.4.0-6ubuntu1~16.04.5 [105 kB]
    Get:19 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libtsan0 amd64 5.4.0-6ubuntu1~16.04.5 [244 kB]
    Get:20 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libubsan0 amd64 5.4.0-6ubuntu1~16.04.5 [95.3 kB]
    Get:21 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libcilkrts5 amd64 5.4.0-6ubuntu1~16.04.5 [40.1 kB]
    Get:22 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libmpx0 amd64 5.4.0-6ubuntu1~16.04.5 [9,786 B]
    Get:23 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libquadmath0 amd64 5.4.0-6ubuntu1~16.04.5 [131 kB]
    Get:24 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libgcc-5-dev amd64 5.4.0-6ubuntu1~16.04.5 [2,226 kB]
    Get:25 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 gcc-5 amd64 5.4.0-6ubuntu1~16.04.5 [8,638 kB]
    Get:26 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 gcc amd64 4:5.3.1-1ubuntu1 [5,244 B]
    Get:27 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libc-dev-bin amd64 2.23-0ubuntu9 [68.6 kB]
    Get:28 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 linux-libc-dev amd64 4.4.0-97.120 [839 kB]
    Get:29 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libc6-dev amd64 2.23-0ubuntu9 [2,082 kB]
    Get:30 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libltdl7 amd64 2.4.6-0.1 [38.3 kB]
    Get:31 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libltdl-dev amd64 2.4.6-0.1 [162 kB]
    Get:32 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libtool all 2.4.6-0.1 [193 kB]
    Get:33 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 manpages-dev all 4.04-2 [2,048 kB]
    Fetched 32.1 MB in 4s (6,918 kB/s)
    Extracting templates from packages: 100%
    Preconfiguring packages ...
    (Reading database ... 64290 files and directories currently installed.)
    Preparing to unpack .../libc6_2.23-0ubuntu9_amd64.deb ...
    Unpacking libc6:amd64 (2.23-0ubuntu9) over (2.23-0ubuntu4) ...
    Setting up libc6:amd64 (2.23-0ubuntu9) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    Selecting previously unselected package libmpc3:amd64.
    (Reading database ... 64290 files and directories currently installed.)
    Preparing to unpack .../libmpc3_1.0.3-1_amd64.deb ...
    Unpacking libmpc3:amd64 (1.0.3-1) ...
    Preparing to unpack .../gcc-5-base_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.5) over (5.4.0-6ubuntu1~16.04.4) ...
    Setting up gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    (Reading database ... 64295 files and directories currently installed.)
    Preparing to unpack .../libstdc++6_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.5) over (5.4.0-6ubuntu1~16.04.4) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    Setting up libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    Selecting previously unselected package m4.
    (Reading database ... 64295 files and directories currently installed.)
    Preparing to unpack .../archives/m4_1.4.17-5_amd64.deb ...
    Unpacking m4 (1.4.17-5) ...
    Selecting previously unselected package autoconf.
    Preparing to unpack .../autoconf_2.69-9_all.deb ...
    Unpacking autoconf (2.69-9) ...
    Selecting previously unselected package autotools-dev.
    Preparing to unpack .../autotools-dev_20150820.1_all.deb ...
    Unpacking autotools-dev (20150820.1) ...
    Selecting previously unselected package automake.
    Preparing to unpack .../automake_1%3a1.15-4ubuntu1_all.deb ...
    Unpacking automake (1:1.15-4ubuntu1) ...
    Selecting previously unselected package binutils.
    Preparing to unpack .../binutils_2.26.1-1ubuntu1~16.04.5_amd64.deb ...
    Unpacking binutils (2.26.1-1ubuntu1~16.04.5) ...
    Selecting previously unselected package libisl15:amd64.
    Preparing to unpack .../libisl15_0.16.1-1_amd64.deb ...
    Unpacking libisl15:amd64 (0.16.1-1) ...
    Selecting previously unselected package cpp-5.
    Preparing to unpack .../cpp-5_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking cpp-5 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package cpp.
    Preparing to unpack .../cpp_4%3a5.3.1-1ubuntu1_amd64.deb ...
    Unpacking cpp (4:5.3.1-1ubuntu1) ...
    Selecting previously unselected package libcc1-0:amd64.
    Preparing to unpack .../libcc1-0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libcc1-0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libgomp1:amd64.
    Preparing to unpack .../libgomp1_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libgomp1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libitm1:amd64.
    Preparing to unpack .../libitm1_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libitm1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libatomic1:amd64.
    Preparing to unpack .../libatomic1_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libatomic1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libasan2:amd64.
    Preparing to unpack .../libasan2_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libasan2:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package liblsan0:amd64.
    Preparing to unpack .../liblsan0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking liblsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libtsan0:amd64.
    Preparing to unpack .../libtsan0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libtsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libubsan0:amd64.
    Preparing to unpack .../libubsan0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libubsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libcilkrts5:amd64.
    Preparing to unpack .../libcilkrts5_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libcilkrts5:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libmpx0:amd64.
    Preparing to unpack .../libmpx0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libmpx0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libquadmath0:amd64.
    Preparing to unpack .../libquadmath0_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libquadmath0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package libgcc-5-dev:amd64.
    Preparing to unpack .../libgcc-5-dev_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking libgcc-5-dev:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package gcc-5.
    Preparing to unpack .../gcc-5_5.4.0-6ubuntu1~16.04.5_amd64.deb ...
    Unpacking gcc-5 (5.4.0-6ubuntu1~16.04.5) ...
    Selecting previously unselected package gcc.
    Preparing to unpack .../gcc_4%3a5.3.1-1ubuntu1_amd64.deb ...
    Unpacking gcc (4:5.3.1-1ubuntu1) ...
    Selecting previously unselected package libc-dev-bin.
    Preparing to unpack .../libc-dev-bin_2.23-0ubuntu9_amd64.deb ...
    Unpacking libc-dev-bin (2.23-0ubuntu9) ...
    Selecting previously unselected package linux-libc-dev:amd64.
    Preparing to unpack .../linux-libc-dev_4.4.0-97.120_amd64.deb ...
    Unpacking linux-libc-dev:amd64 (4.4.0-97.120) ...
    Selecting previously unselected package libc6-dev:amd64.
    Preparing to unpack .../libc6-dev_2.23-0ubuntu9_amd64.deb ...
    Unpacking libc6-dev:amd64 (2.23-0ubuntu9) ...
    Selecting previously unselected package libltdl7:amd64.
    Preparing to unpack .../libltdl7_2.4.6-0.1_amd64.deb ...
    Unpacking libltdl7:amd64 (2.4.6-0.1) ...
    Selecting previously unselected package libltdl-dev:amd64.
    Preparing to unpack .../libltdl-dev_2.4.6-0.1_amd64.deb ...
    Unpacking libltdl-dev:amd64 (2.4.6-0.1) ...
    Selecting previously unselected package libtool.
    Preparing to unpack .../libtool_2.4.6-0.1_all.deb ...
    Unpacking libtool (2.4.6-0.1) ...
    Selecting previously unselected package manpages-dev.
    Preparing to unpack .../manpages-dev_4.04-2_all.deb ...
    Unpacking manpages-dev (4.04-2) ...
    Processing triggers for install-info (6.1.0.dfsg.1-5) ...
    Processing triggers for man-db (2.7.5-1) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    Setting up libmpc3:amd64 (1.0.3-1) ...
    Setting up m4 (1.4.17-5) ...
    Setting up autoconf (2.69-9) ...
    Setting up autotools-dev (20150820.1) ...
    Setting up automake (1:1.15-4ubuntu1) ...
    update-alternatives: using /usr/bin/automake-1.15 to provide /usr/bin/automake (automake) in auto mode
    Setting up binutils (2.26.1-1ubuntu1~16.04.5) ...
    Setting up libisl15:amd64 (0.16.1-1) ...
    Setting up cpp-5 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up cpp (4:5.3.1-1ubuntu1) ...
    Setting up libcc1-0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libgomp1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libitm1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libatomic1:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libasan2:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up liblsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libtsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libubsan0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libcilkrts5:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libmpx0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libquadmath0:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up libgcc-5-dev:amd64 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up gcc-5 (5.4.0-6ubuntu1~16.04.5) ...
    Setting up gcc (4:5.3.1-1ubuntu1) ...
    Setting up libc-dev-bin (2.23-0ubuntu9) ...
    Setting up linux-libc-dev:amd64 (4.4.0-97.120) ...
    Setting up libc6-dev:amd64 (2.23-0ubuntu9) ...
    Setting up libltdl7:amd64 (2.4.6-0.1) ...
    Setting up libltdl-dev:amd64 (2.4.6-0.1) ...
    Setting up libtool (2.4.6-0.1) ...
    Setting up manpages-dev (4.04-2) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    azureuser@myvm:~$


Step (7): Install other Mesos dependencies.

    $ sudo apt-get -y install build-essential python-dev python-six python-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev

Output (Git Bash CLI):
    azureuser@myvm:~$ sudo apt-get -y install build-essential python-dev python-six python-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    libsasl2-modules is already the newest version (2.1.26.dfsg1-14build1).
    The following additional packages will be installed:
      ant ant-optional dpkg-dev fakeroot g++ g++-5 junit junit4 libalgorithm-diff-perl libalgorithm-diff-xs-perl
      libalgorithm-merge-perl libaopalliance-java libapache-pom-java libapr1 libaprutil1 libaprutil1-dev
      libasm4-java libatinject-jsr330-api-java libbsh-java libcdi-api-java libcglib3-java libclassworlds-java
      libcommons-cli-java libcommons-codec-java libcommons-httpclient-java libcommons-io-java libcommons-lang-java
      libcommons-lang3-java libcommons-logging-java libcommons-net-java libcommons-net2-java
      libcommons-parent-java libcurl3-nss libdom4j-java libdoxia-core-java libdpkg-perl libeasymock-java
      libeclipse-aether-java libexpat1 libexpat1-dev libfakeroot libfile-fcntllock-perl
      libgeronimo-interceptor-3.0-spec-java libguava-java libguice-java libhamcrest-java libhttpclient-java
      libhttpcore-java libjaxen-java libjaxp1.3-java libjdom1-java libjetty-java libjsch-java libjsoup-java
      libjsr305-java libldap-2.4-2 libldap2-dev liblog4j1.2-java libmaven-parent-java libmaven2-core-java
      libmaven3-core-java libobjenesis-java libplexus-ant-factory-java libplexus-archiver-java
      libplexus-bsh-factory-java libplexus-cipher-java libplexus-classworlds-java libplexus-classworlds2-java
      libplexus-cli-java libplexus-component-annotations-java libplexus-component-metadata-java
      libplexus-container-default-java libplexus-container-default1.5-java libplexus-containers-java
      libplexus-containers1.5-java libplexus-interactivity-api-java libplexus-interpolation-java libplexus-io-java
      libplexus-sec-dispatcher-java libplexus-utils-java libplexus-utils2-java libpython-dev libpython2.7
      libpython2.7-dev libpython2.7-minimal libpython2.7-stdlib libqdox2-java libsctp-dev libsctp1 libserf-1-1
      libservlet2.5-java libservlet3.1-java libsisu-inject-java libsisu-plexus-java libslf4j-java libstdc++-5-dev
      libsvn1 libuuid1 libwagon-java libwagon2-java libxalan2-java libxbean-java libxerces2-java
      libxml-commons-external-java libxml-commons-resolver1.1-java libxom-java libxpp2-java libxpp3-java make
      python-pip-whl python-pkg-resources python2.7 python2.7-dev python2.7-minimal python3-virtualenv uuid-dev
      virtualenv zlib1g
    Suggested packages:
      ant-doc ant-gcj ant-optional-gcj antlr javacc jython libbcel-java libbsf-java libgnumail-java
      libjdepend-java liboro-java libregexp-java debian-keyring g++-multilib g++-5-multilib gcc-5-doc
      libstdc++6-5-dbg junit-doc libaopalliance-java-doc libatinject-jsr330-api-java-doc libclassworlds-java-doc
      libcommons-httpclient-java-doc libcommons-io-java-doc libcommons-lang-java-doc libcommons-lang3-java-doc
      libavalon-framework-java libcommons-logging-java-doc libexcalibur-logkit-java libcommons-net-java-doc
      libcommons-net2-java-doc libcurl4-doc libcurl3-dbg libidn11-dev libkrb5-dev libnss3-dev librtmp-dev
      pkg-config libdom4j-java-doc libeasymock-java-doc libcglib-java libjaxp1.3-java-gcj libjdom1-java-doc jetty
      libjetty-java-doc libjsoup-java-doc libjsr305-java-doc liblog4j1.2-java-doc libobjenesis-java-doc
      libplexus-cipher-java-doc libplexus-classworlds-java-doc libplexus-classworlds2-java-doc
      libplexus-cli-java-doc libplexus-container-default-java-doc libplexus-interactivity-api-java-doc
      libplexus-interpolation-java-doc libplexus-sec-dispatcher-java-doc libplexus-utils-java-doc
      libplexus-utils2-java-doc libqdox2-java-doc lksctp-tools testng libstdc++-5-doc libserf-dev libsvn-doc
      libwagon-java-doc libxalan2-java-doc libxsltc-java groovy2 libequinox-osgi-java libosgi-compendium-java
      libosgi-core-java libqdox-java libspring-beans-java libspring-context-java libspring-core-java
      libspring-web-java libxerces2-java-doc libxerces2-java-gcj libxml-commons-resolver1.1-java-doc
      libxom-java-doc make-doc python-setuptools python2.7-doc binfmt-support
    The following NEW packages will be installed:
      ant ant-optional build-essential dpkg-dev fakeroot g++ g++-5 junit junit4 libalgorithm-diff-perl
      libalgorithm-diff-xs-perl libalgorithm-merge-perl libaopalliance-java libapache-pom-java libapr1 libapr1-dev
      libaprutil1 libaprutil1-dev libasm4-java libatinject-jsr330-api-java libbsh-java libcdi-api-java
      libcglib3-java libclassworlds-java libcommons-cli-java libcommons-codec-java libcommons-httpclient-java
      libcommons-io-java libcommons-lang-java libcommons-lang3-java libcommons-logging-java libcommons-net-java
      libcommons-net2-java libcommons-parent-java libcurl3-nss libcurl4-nss-dev libdom4j-java libdoxia-core-java
      libdpkg-perl libeasymock-java libeclipse-aether-java libexpat1-dev libfakeroot libfile-fcntllock-perl
      libgeronimo-interceptor-3.0-spec-java libguava-java libguice-java libhamcrest-java libhttpclient-java
      libhttpcore-java libjaxen-java libjaxp1.3-java libjdom1-java libjetty-java libjsch-java libjsoup-java
      libjsr305-java libldap2-dev liblog4j1.2-java libmaven-parent-java libmaven2-core-java libmaven3-core-java
      libobjenesis-java libplexus-ant-factory-java libplexus-archiver-java libplexus-bsh-factory-java
      libplexus-cipher-java libplexus-classworlds-java libplexus-classworlds2-java libplexus-cli-java
      libplexus-component-annotations-java libplexus-component-metadata-java libplexus-container-default-java
      libplexus-container-default1.5-java libplexus-containers-java libplexus-containers1.5-java
      libplexus-interactivity-api-java libplexus-interpolation-java libplexus-io-java
      libplexus-sec-dispatcher-java libplexus-utils-java libplexus-utils2-java libpython-dev libpython2.7-dev
      libqdox2-java libsasl2-dev libsctp-dev libsctp1 libserf-1-1 libservlet2.5-java libservlet3.1-java
      libsisu-inject-java libsisu-plexus-java libslf4j-java libstdc++-5-dev libsvn-dev libsvn1 libwagon-java
      libwagon2-java libxalan2-java libxbean-java libxerces2-java libxml-commons-external-java
      libxml-commons-resolver1.1-java libxom-java libxpp2-java libxpp3-java make maven python-dev python-pip-whl
      python-pkg-resources python-six python-virtualenv python2.7-dev python3-virtualenv uuid-dev virtualenv
      zlib1g-dev
    The following packages will be upgraded:
      libexpat1 libldap-2.4-2 libpython2.7 libpython2.7-minimal libpython2.7-stdlib libuuid1 python2.7
      python2.7-minimal zlib1g
    9 upgraded, 119 newly installed, 0 to remove and 189 not upgraded.
    Need to get 78.6 MB/78.7 MB of archives.
    After this operation, 159 MB of additional disk space will be used.
    Get:1 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libuuid1 amd64 2.27.1-6ubuntu3.3 [15.7 kB]
    Get:2 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libapr1 amd64 1.5.2-3 [86.0 kB]
    Get:3 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 libexpat1 amd64 2.1.0-7ubuntu0.16.04.3 [71.2 kB]
    Get:4 <http://azure.archive.ubuntu.com/ubuntu xenial/main> amd64 libaprutil1 amd64 1.5.4-1build1 [77.1 kB]
    Get:5 <http://azure.archive.ubuntu.com/ubuntu xenial-updates/main> amd64 zlib1g amd64 1:1.2.8.dfsg-2ubuntu4.1 [51.2 kB]

    ...

    Setting up python2.7-dev (2.7.12-1ubuntu0~16.04.1) ...
    Setting up python-dev (2.7.11-1) ...
    Setting up python-pip-whl (8.1.1-2ubuntu0.4) ...
    Setting up python-pkg-resources (20.7.0-1) ...
    Setting up python-six (1.10.0-3) ...
    Setting up python-virtualenv (15.0.1+ds-3ubuntu1) ...
    Setting up python3-virtualenv (15.0.1+ds-3ubuntu1) ...
    Setting up virtualenv (15.0.1+ds-3ubuntu1) ...
    Setting up zlib1g-dev:amd64 (1:1.2.8.dfsg-2ubuntu4.1) ...
    Setting up libsvn-dev (1.9.3-2ubuntu1.1) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    azureuser@myvm:~$


Step (8): Building Mesos (Posix)
# Change working directory.
    $ cd mesos

# Bootstrap (Only required if building from git repository).
    $ ./bootstrap

Output (Git Bash CLI):
    azureuser@myvm:~/mesos$ ./bootstrap
    autoreconf: Entering directory `.'
    autoreconf: configure.ac: not using Gettext
    autoreconf: running: aclocal --warnings=all -I m4
    autoreconf: configure.ac: tracing
    configure.ac:1471: warning: cannot check for file existence when cross compiling
    ../../lib/autoconf/general.m4:2788: AC_CHECK_FILE is expanded from...
    configure.ac:1471: the top level
    configure.ac:2054: warning: AC_RUN_IFELSE called without default to allow cross compiling
    ../../lib/autoconf/general.m4:2759: AC_RUN_IFELSE is expanded from...
    configure.ac:2054: the top level
    autoreconf: running: libtoolize --copy
    libtoolize: putting auxiliary files in '.'.
    libtoolize: copying file './ltmain.sh'
    libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'm4'.
    libtoolize: copying file 'm4/libtool.m4'
    libtoolize: copying file 'm4/ltoptions.m4'
    libtoolize: copying file 'm4/ltsugar.m4'
    libtoolize: copying file 'm4/ltversion.m4'
    libtoolize: copying file 'm4/lt~obsolete.m4'
    autoreconf: running: /usr/bin/autoconf --warnings=all
    configure.ac:1471: warning: cannot check for file existence when cross compiling
    ../../lib/autoconf/general.m4:2788: AC_CHECK_FILE is expanded from...
    configure.ac:1471: the top level
    configure.ac:2054: warning: AC_RUN_IFELSE called without default to allow cross compiling
    ../../lib/autoconf/general.m4:2759: AC_RUN_IFELSE is expanded from...
    configure.ac:2054: the top level
    autoreconf: configure.ac: not using Autoheader
    autoreconf: running: automake --add-missing --copy --no-force --warnings=all
    configure.ac:50: installing './ar-lib'
    configure.ac:34: installing './compile'
    configure.ac:24: installing './config.guess'
    configure.ac:24: installing './config.sub'
    configure.ac:46: installing './install-sh'
    configure.ac:46: installing './missing'
    3rdparty/Makefile.am:246: warning: source file '$(HTTP_PARSER)/http_parser.c' is in a subdirectory,
    3rdparty/Makefile.am:246: but option 'subdir-objects' is disabled
    automake: warning: possible forward-incompatibility.
    automake: At least a source file is in a subdirectory, but the 'subdir-objects'
    automake: automake option hasn't been enabled.  For now, the corresponding output
    automake: object file(s) will be placed in the top-level directory.  However,
    automake: this behaviour will change in future Automake versions: they will
    automake: unconditionally cause object files to be placed in the same subdirectory
    automake: of the corresponding sources.
    automake: You are advised to start using 'subdir-objects' option throughout your
    automake: project, to avoid future incompatibilities.
    3rdparty/Makefile.am: installing './depcomp'
    3rdparty/Makefile.am:208: warning: variable 'GLOG_LDFLAGS' is defined but no program or
    3rdparty/Makefile.am:208: library has 'GLOG' as canonical name (possible typo)
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/authenticator_manager.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/authenticator.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/clock.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/firewall.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/help.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/http.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/io.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/latch.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/logging.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/metrics/metrics.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/mime.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/pid.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/poll_socket.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/profiler.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/process.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/reap.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/socket.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/subprocess.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/subprocess_posix.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/time.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:188: warning: source file 'src/timeseries.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:188: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:224: warning: source file 'src/jwt.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:224: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:224: warning: source file 'src/jwt_authenticator.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:224: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:224: warning: source file 'src/libevent_ssl_socket.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:224: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:224: warning: source file 'src/openssl.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:224: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:224: warning: source file 'src/ssl/utilities.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:224: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:255: warning: source file 'src/grpc.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:255: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:260: warning: source file 'src/libevent.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:260: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:260: warning: source file 'src/libevent_poll.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:260: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:265: warning: source file 'src/libev.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:265: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:265: warning: source file 'src/libev_poll.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:265: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:350: warning: source file 'src/tests/benchmarks.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:350: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/after_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/collect_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/count_down_latch_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/decoder_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/encoder_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/future_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/http_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/io_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/limiter_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/loop_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/main.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/metrics_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/mutex_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/owned_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/process_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/profiler_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/queue_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/reap_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/socket_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/sequence_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/shared_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/statistics_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/subprocess_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/system_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/timeseries_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:287: warning: source file 'src/tests/time_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:287: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:328: warning: source file 'src/tests/grpc_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:328: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:345: warning: source file 'src/tests/jwt_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:345: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:345: warning: source file 'src/tests/ssl_tests.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:345: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:341: warning: source file 'src/tests/ssl_client.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:341: but option 'subdir-objects' is disabled
    3rdparty/libprocess/Makefile.am:371: warning: source file 'src/tests/test_linkee.cpp' is in a subdirectory,
    3rdparty/libprocess/Makefile.am:371: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/adaptor_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/base64_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/bits_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/boundedhashmap_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/bytes_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/cache_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/duration_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/dynamiclibrary_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/error_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/flags_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/gzip_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/hashmap_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/hashset_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/interval_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/ip_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/json_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/jsonify_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/lambda_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/linkedhashmap_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/mac_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/main.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/multimap_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/none_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/numify_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/option_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/env_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/filesystem_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/process_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/rmdir_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/sendfile_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/signals_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/socket_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/strerror_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/os/systems_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/path_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/protobuf_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/recordio_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/result_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/some_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/strings_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/subcommand_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/svn_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/try_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/uuid_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/variant_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:128: warning: source file 'tests/version_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:128: but option 'subdir-objects' is disabled
    3rdparty/stout/Makefile.am:179: warning: source file 'tests/proc_tests.cpp' is in a subdirectory,
    3rdparty/stout/Makefile.am:179: but option 'subdir-objects' is disabled
    autoreconf: Leaving directory `.'
    azureuser@myvm:~/mesos$


Step (8): Configure and build.

    $ mkdir build
    $ cd build

Output (Git Bash CLI):
    azureuser@myvm:~/mesos$ mkdir build
    azureuser@myvm:~/mesos$ cd build
    azureuser@myvm:~/mesos/build$

$ ../configure

Output (Git Bash CLI):
    azureuser@myvm:~/mesos/build$ ../configure
    checking build system type... x86_64-pc-linux-gnu
    checking host system type... x86_64-pc-linux-gnu
    checking target system type... x86_64-pc-linux-gnu
    checking for g++... g++
    checking whether the C++ compiler works... yes
    checking for C++ compiler default output file name... a.out
    checking for suffix of executables...
    checking whether we are cross compiling... no
    checking for suffix of object files... o
    checking whether we are using the GNU C++ compiler... yes
    checking whether g++ accepts -g... yes
    checking for gcc... gcc
    checking whether we are using the GNU C compiler... yes
    checking whether gcc accepts -g... yes
    checking for gcc option to accept ISO C89... none needed
    checking whether gcc understands -c and -o together... yes
    checking whether ln -s works... yes
    checking for C++ compiler vendor... gnu
    checking for a sed that does not truncate output... /bin/sed
    checking for C++ compiler version... 5.4.0
    checking for C++ compiler vendor... (cached) gnu
    checking for a BSD-compatible install... /usr/bin/install -c
    checking whether build environment is sane... yes
    checking for a thread-safe mkdir -p... /bin/mkdir -p
    checking for gawk... gawk
    checking whether make sets $(MAKE)... yes
    checking for style of include used by make... GNU
    checking whether make supports nested variables... yes
    checking dependency style of gcc... gcc3
    checking dependency style of g++... gcc3
    checking whether to enable maintainer-specific portions of Makefiles... yes
    checking for ar... ar
    checking the archiver (ar) interface... ar
    checking how to print strings... printf
    checking for a sed that does not truncate output... (cached) /bin/sed
    checking for grep that handles long lines and -e... /bin/grep
    checking for egrep... /bin/grep -E
    checking for fgrep... /bin/grep -F
    checking for ld used by gcc... /usr/bin/ld
    checking if the linker (/usr/bin/ld) is GNU ld... yes
    checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
    checking the name lister (/usr/bin/nm -B) interface... BSD nm
    checking the maximum length of command line arguments... 1572864
    checking how to convert x86_64-pc-linux-gnu file names to x86_64-pc-linux-gnu format... func_convert_file_noop
    checking how to convert x86_64-pc-linux-gnu file names to toolchain format... func_convert_file_noop
    checking for /usr/bin/ld option to reload object files... -r
    checking for objdump... objdump
    checking how to recognize dependent libraries... pass_all
    checking for dlltool... no
    checking how to associate runtime and link libraries... printf %s\n
    checking for archiver @FILE support... @
    checking for strip... strip
    checking for ranlib... ranlib
    checking command to parse /usr/bin/nm -B output from gcc object... ok
    checking for sysroot... no
    checking for a working dd... /bin/dd
    checking how to truncate binary pipes... /bin/dd bs=4096 count=1
    checking for mt... mt
    checking if mt is a manifest tool... no
    checking how to run the C preprocessor... gcc -E
    checking for ANSI C header files... yes
    checking for sys/types.h... yes
    checking for sys/stat.h... yes
    checking for stdlib.h... yes
    checking for string.h... yes
    checking for memory.h... yes
    checking for strings.h... yes
    checking for inttypes.h... yes
    checking for stdint.h... yes
    checking for unistd.h... yes
    checking for dlfcn.h... yes
    checking for objdir... .libs
    checking if gcc supports -fno-rtti -fno-exceptions... no
    checking for gcc option to produce PIC... -fPIC -DPIC
    checking if gcc PIC flag -fPIC -DPIC works... yes
    checking if gcc static flag -static works... yes
    checking if gcc supports -c -o file.o... yes
    checking if gcc supports -c -o file.o... (cached) yes
    checking whether the gcc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
    checking whether -lc should be explicitly linked in... no
    checking dynamic linker characteristics... GNU/Linux ld.so
    checking how to hardcode library paths into programs... immediate
    checking whether stripping libraries is possible... yes
    checking if libtool supports shared libraries... yes
    checking whether to build shared libraries... yes
    checking whether to build static libraries... no
    checking how to run the C++ preprocessor... g++ -E
    checking for ld used by g++... /usr/bin/ld -m elf_x86_64
    checking if the linker (/usr/bin/ld -m elf_x86_64) is GNU ld... yes
    checking whether the g++ linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
    checking for g++ option to produce PIC... -fPIC -DPIC
    checking if g++ PIC flag -fPIC -DPIC works... yes
    checking if g++ static flag -static works... yes
    checking if g++ supports -c -o file.o... yes
    checking if g++ supports -c -o file.o... (cached) yes
    checking whether the g++ linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
    checking dynamic linker characteristics... (cached) GNU/Linux ld.so
    checking how to hardcode library paths into programs... immediate
    configure: creating ./config.lt
    config.lt: creating libtool
    configure: Setting up CXXFLAGS for g++ version >= 4.8
    checking whether C++ compiler accepts -fstack-protector-strong... yes
    checking whether g++ supports C++11 features by default... no
    checking whether g++ supports C++11 features with -std=c++11... yes
    checking if compiler needs -Werror to reject unknown flags... no
    checking for the pthreads library -lpthreads... no
    checking whether pthreads work without any flags... no
    checking whether pthreads work with -Kthread... no
    checking whether pthreads work with -kthread... no
    checking for the pthreads library -llthread... no
    checking whether pthreads work with -pthread... yes
    checking for joinable pthread attribute... PTHREAD_CREATE_JOINABLE
    checking if more special flags are required for pthreads... no
    checking for PTHREAD_PRIO_INHERIT... yes
    configure: Setting up build environment for x86_64 linux-gnu
    checking for backtrace in -lunwind... no
    checking for main in -lgflags... no
    checking for patch... patch
    checking fts.h usability... yes
    checking fts.h presence... yes
    checking for fts.h... yes
    checking for library containing fts_close... none required
    checking apr_pools.h usability... yes
    checking apr_pools.h presence... yes
    checking for apr_pools.h... yes
    checking for apr_initialize in -lapr-1... yes
    checking for curl_global_init in -lcurl... yes
    checking for javac... /usr/bin/javac
    checking for java... /usr/bin/java
    checking value of Java system property 'java.home'... /usr/lib/jvm/java-8-openjdk-amd64/jre
    configure: using JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    checking whether or not we can build with JNI... yes
    checking for mvn... /usr/bin/mvn
    checking for sasl_done in -lsasl2... yes
    checking SASL CRAM-MD5 support... yes
    checking for RAND_poll in -lcrypto... no
    checking openssl/ssl.h usability... no
    checking openssl/ssl.h presence... no
    checking for openssl/ssl.h... no
    checking svn_version.h usability... yes
    checking svn_version.h presence... yes
    checking for svn_version.h... yes
    checking for svn_stringbuf_create_ensure in -lsvn_subr-1... yes
    checking svn_delta.h usability... yes
    checking svn_delta.h presence... yes
    checking for svn_delta.h... yes
    checking for svn_txdelta in -lsvn_delta-1... yes
    checking whether to enable the XFS disk isolator... no
    checking zlib.h usability... yes
    checking zlib.h presence... yes
    checking for zlib.h... yes
    checking for deflate, gzread, gzwrite, inflate in -lz... yes
    checking C++ standard library for undefined behaviour with selected optimization level... no
    checking for a Python interpreter with version >= 2.6... python
    checking for python... /usr/bin/python
    checking for python version... 2.7
    checking for python platform... linux2
    checking for python script directory... ${prefix}/lib/python2.7/site-packages
    checking for python extension module directory... ${exec_prefix}/lib/python2.7/site-packages
    checking for python2.7... (cached) /usr/bin/python
    checking for a version of Python >= '2.1.0'... yes
    checking for a version of Python >= '2.6'... yes
    checking for the distutils Python package... yes
    checking for Python include path... -I/usr/include/python2.7
    checking for Python library path... -L/usr/lib -lpython2.7
    checking for Python site-packages path... /usr/lib/python2.7/dist-packages
    checking python extra libraries... -lpthread -ldl  -lutil -lm
    checking python extra linking flags... -Xlinker -export-dynamic -Wl,-O1 -Wl,-Bsymbolic-functions
    checking consistency of all components of python development environment... yes
    checking whether we can build usable Python eggs... cc1plus: warning: command line option '-Wstrict-prototypes' is valid for C/ObjC but not for C++
    yes
    checking for an old installation of the Mesos egg (before 0.20.0)... no
    checking that generated files are newer than configure... done
    configure: creating ./config.status
    config.status: creating Makefile
    config.status: creating mesos.pc
    config.status: creating src/Makefile
    config.status: creating 3rdparty/Makefile
    config.status: creating 3rdparty/libprocess/Makefile
    config.status: creating 3rdparty/libprocess/include/Makefile
    config.status: creating 3rdparty/stout/Makefile
    config.status: creating 3rdparty/stout/include/Makefile
    config.status: creating 3rdparty/gmock_sources.cc
    config.status: creating bin/mesos.sh
    config.status: creating bin/mesos-agent.sh
    config.status: creating bin/mesos-local.sh
    config.status: creating bin/mesos-master.sh
    config.status: creating bin/mesos-slave.sh
    config.status: creating bin/mesos-tests.sh
    config.status: creating bin/mesos-agent-flags.sh
    config.status: creating bin/mesos-local-flags.sh
    config.status: creating bin/mesos-master-flags.sh
    config.status: creating bin/mesos-slave-flags.sh
    config.status: creating bin/mesos-tests-flags.sh
    config.status: creating bin/gdb-mesos-agent.sh
    config.status: creating bin/gdb-mesos-local.sh
    config.status: creating bin/gdb-mesos-master.sh
    config.status: creating bin/gdb-mesos-slave.sh
    config.status: creating bin/gdb-mesos-tests.sh
    config.status: creating bin/lldb-mesos-agent.sh
    config.status: creating bin/lldb-mesos-local.sh
    config.status: creating bin/lldb-mesos-master.sh
    config.status: creating bin/lldb-mesos-slave.sh
    config.status: creating bin/lldb-mesos-tests.sh
    config.status: creating bin/valgrind-mesos-agent.sh
    config.status: creating bin/valgrind-mesos-local.sh
    config.status: creating bin/valgrind-mesos-master.sh
    config.status: creating bin/valgrind-mesos-slave.sh
    config.status: creating bin/valgrind-mesos-tests.sh
    config.status: creating src/deploy/mesos-daemon.sh
    config.status: creating src/deploy/mesos-start-agents.sh
    config.status: creating src/deploy/mesos-start-cluster.sh
    config.status: creating src/deploy/mesos-start-masters.sh
    config.status: creating src/deploy/mesos-start-slaves.sh
    config.status: creating src/deploy/mesos-stop-agents.sh
    config.status: creating src/deploy/mesos-stop-cluster.sh
    config.status: creating src/deploy/mesos-stop-masters.sh
    config.status: creating src/deploy/mesos-stop-slaves.sh
    config.status: creating include/mesos/version.hpp
    config.status: creating src/java/generated/org/apache/mesos/MesosNativeLibrary.java
    config.status: creating mpi/mpiexec-mesos
    config.status: creating src/examples/java/test-exception-framework
    config.status: creating src/examples/java/test-executor
    config.status: creating src/examples/java/test-framework
    config.status: creating src/examples/java/test-multiple-executors-framework
    config.status: creating src/examples/java/test-log
    config.status: creating src/examples/java/v1-test-framework
    config.status: creating src/java/mesos.pom
    config.status: creating src/examples/python/test-executor
    config.status: creating src/examples/python/test-framework
    config.status: creating src/python/setup.py
    config.status: creating src/python/cli/setup.py
    config.status: creating src/python/interface/setup.py
    config.status: creating src/python/native_common/ext_modules.py
    config.status: creating src/python/executor/setup.py
    config.status: creating src/python/native/setup.py
    config.status: creating src/python/scheduler/setup.py
    config.status: linking src/python/native_common/ext_modules.py to src/python/executor/ext_modules.py
    config.status: linking src/python/native_common/ext_modules.py to src/python/scheduler/ext_modules.py
    config.status: executing depfiles commands
    config.status: executing libtool commands
    configure: Build option summary:
        CXX:        g++
        CXXFLAGS:   -g1 -O0 -Wno-unused-local-typedefs -std=c++11
        CPPFLAGS:   -isystem /usr/include/subversion-1 -isystem /usr/include/apr-1 -isystem /usr/include/apr-1.0    
        LDFLAGS:
        LIBS:       -lz -lsvn_delta-1 -lsvn_subr-1 -lsasl2 -lcurl -lapr-1  -lrt

    azureuser@myvm:~/mesos/build$

Step (9): Make

In order to speed up the build and reduce verbosity of the logs, you can append -j <number of cores> V=0 to make.

    $ make

Output (Git Bash CLI):
    azureuser@myvm:~/mesos/build$make
 
********
Summary:
********
You have installed Terraform and configured Azure credentials so that you can start deploying infrastructure into your Azure subscription. You then tested your installation by creating a complete Virtual Machine w/Ubuntu Linux OS and other related resources in Azure.

 **********
 Resources:
 **********
    Terraform Provider: azurerm_virtual_machine: https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html
 
 Gettring Started with Terraform: 
 
     Instroduction: https://www.terraform.io/intro/index.html

     Install Terraform: https://www.terraform.io/intro/getting-started/install.html

     Build Infrastructure: https://www.terraform.io/intro/getting-started/build.html

     Provision: https://www.terraform.io/intro/getting-started/provision.html

     Change Infrastructure: https://www.terraform.io/intro/getting-started/change.html

     Destroy Infrastructure: https://www.terraform.io/intro/getting-started/destroy.html
 
