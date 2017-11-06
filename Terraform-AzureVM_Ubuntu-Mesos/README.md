This is a Terraform sample demo lab to create a complete Linux Ubuntu virtual machine and other associated ARM resources in Azure with Terraform, which includes the following ARM resources:

    - Azure connection 
    - Resource group
    - Virtual network
    - Public IP address
    - Network Security Group
    - Virtual network interface card
    - Storage account for diagnostics
    - Virtual machine

You can define and create complete infrastructure deployments across multiple cloud providers using a Terraform template, which is build in a human-readable format.  Microsoft AzureRM provider templates enables you to consistently create and configure Azure resources, and is reusable across your organization. This demo lab shows you how to create a complete Linux environment and supporting resources with Terraform.

This demo lab uses the "azurerm_virtual_machine" Azure provider template for Terraform to express infrastructure-as-code, and to deploy Azure Virtual Machine instance and other associated ARM resources.  In this demo lab, Terraform Microsoft AzureRM Provider will interact with the Azure Resource Manager resources via the AzureRM API's. Prior to your Azure resource deployment, the AzureRM provider for Terraform needs to be configured with the credentials needed to generate OAuth tokens for the AzureRM API's.

Once the VM is created in Azure, you will ssh into the VM to download/extract Mesos release tar.gz archive for your operating system, configure/build Mesos, and make framework binearies bundled with Mesos (see link below).

http://mesos.apache.org/documentation/latest/building/

For more details, please see the "Install and configure Terraform to provision VMs and other infrastructure into Azure" Microsoft Docs link below:

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure


**************************************************************
Part I. Install Terraform and create AzureRM provider template
**************************************************************
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

Step (4.1) Go to browser and navigate to: https://aka.ms/devicelogin

Setp (4.2) Azure authentication with Device Login code: EJGA3L6Q7

Step (4.3) Click <Continue> > to select azure account to login

Step (4.4) Azure CLI - Azure authenticated

Step (4.5) Go back to CLI - Completed authentication with Azure

Output:

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

Step (5): (Optional) Set subscription ID for the sesssion

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

Copy and paster the followig content into the Create-VM-StdA0.tf configuration file:

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
Create a complete AzureRM VM with Ubuntu Linux OS and other associated Azure resources.

step (1): Initialize Terraform. 

This step ensures that Terraform has all the prerequisites to build your template in Azure.

Terraform configuration file: Create-VM-StdA0.tf

Note:
- VM Size is set to "Standard A0" for demo purposes
- OSDisk is set to "Standard LRS"

    $ terraform init

Output:

    C:\{tf directory}\>terraform init

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


Step (2): Terraform review and validate the template. 

This step compares the requested resources to the state information saved by Terraform and then outputs the planned execution. Resources are not created in Azure.

    $ terraform plan

Output:

    C:\{tf directory}\>terraform plan

    There are warnings related to your configuration. If no errors occurred, Terraform will continue despite these warnings. It is a good idea to resolve these warnings in the near future.

    Warnings:

      * azurerm_storage_account.mystorageaccount: "account_type": [DEPRECATED] This field has been split into `account_tier` and `account_replication_type`

    2 error(s) occurred:

    * azurerm_storage_account.mystorageaccount: "account_replication_type": required field is not set

    * azurerm_storage_account.mystorageaccount: "account_tier": required field is not set

Step (3): Execution Plan

Run "terraform plan" in the same directory where "Create-VM-StdA0.tf" was created to determine Terraform's execution plan when it apply this configuration.

    $ terraform plan

Output:

    $ C:\{tf directory}\>terraform plan
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

    C:\{tf directory}\>terraform apply
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

    C:\{tf directory}\>az vm show --resource-group myResourceGroup --name myVM -d --query [publicIps] --o tsv

    52.179.14.5


Step (6): SSH into the VM 

SSH into the VM using the public IP address obtained above via Git Bash CLI to install Mesos on Ubuntu

    $ ssh azureuser@<publicIps>

Output - Git Bash CLI:

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

Step (1): Download Mesos

Download latest stable Mesos release from Apache and extract tar file

    $ wget http://www.apache.org/dist/mesos/1.4.0/mesos-1.4.0.tar.gz
    $ tar -zxf mesos-1.4.0.tar.gz

Output - Git Bash CLI:

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

Output - Git Bash CLI:

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

Output - Git Bash CLI (truncated):

    azureuser@myvm:~$ sudo apt-get update
    Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [102 kB]
    Hit:2 http://azure.archive.ubuntu.com/ubuntu xenial InRelease
    Get:3 http://azure.archive.ubuntu.com/ubuntu xenial-updates InRelease [102 kB]
    ...{snip}
    Get:38 <http://azure.archive.ubuntu.com/ubuntu xenial-backports/universe> Translation-en [3,060 B]
    Fetched 12.2 MB in 9s (1,330 kB/s)
    Reading package lists... Done
    azureuser@myvm:~$

Step (4): Install a few utility tools.

    $ sudo apt-get install -y tar wget git

Output - Git Bash CLI:

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

Output - Git Bash CLI (truncated):

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
    ...{snip}
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

Output-Git Bash CLI (truncated):

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
    ... {snip}
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
    ...{snip}
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
    ...{snip}
    Setting up manpages-dev (4.04-2) ...
    Processing triggers for libc-bin (2.23-0ubuntu4) ...
    azureuser@myvm:~$


Step (7): Install other Mesos dependencies.

    $ sudo apt-get -y install build-essential python-dev python-six python-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev

Output - Git Bash CLI (truncated):

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
    ...{snip}
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
    ...{snip}
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

Change working directory.

    $ cd mesos

Bootstrap (Only required if building from git repository).

    $ ./bootstrap

Output - Git Bash CLI (truncated):

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
    ...{snip}
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
    ...{snip}
    configure.ac:46: installing './missing'
    3rdparty/Makefile.am:246: warning: source file '$(HTTP_PARSER)/http_parser.c' is in a subdirectory,
    3rdparty/Makefile.am:246: but option 'subdir-objects' is disabled
    automake: warning: possible forward-incompatibility.
    ...{snip}
    automake: project, to avoid future incompatibilities.
    3rdparty/Makefile.am: installing './depcomp'
    ...{snip}
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
    ...{snip}
    checking whether we can build usable Python eggs... cc1plus: warning: command line option '-Wstrict-prototypes' is valid for C/ObjC but not for C++
    yes
    checking for an old installation of the Mesos egg (before 0.20.0)... no
    checking that generated files are newer than configure... done
    configure: creating ./config.status
    config.status: creating Makefile
    config.status: creating mesos.pc
    config.status: creating src/Makefile
    config.status: creating 3rdparty/Makefile
    ...{snip}
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
You have installed Terraform and configured Azure credentials so that you can start deploying infrastructure into your Azure subscription. You then tested your installation by creating a complete Virtual Machine w/Ubuntu Linux OS and other related resources in Azure.  Once you have built the Azure VM, you then ssh into the VM to download and install Mesos.

 **********
 Resources:
 **********
    Terraform Provider: azurerm_virtual_machine: https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html
    Mesos Build: http://mesos.apache.org/documentation/latest/building/
 
 Gettring Started with Terraform: 
 
     Instroduction: https://www.terraform.io/intro/index.html

     Install Terraform: https://www.terraform.io/intro/getting-started/install.html

     Build Infrastructure: https://www.terraform.io/intro/getting-started/build.html

     Provision: https://www.terraform.io/intro/getting-started/provision.html

     Change Infrastructure: https://www.terraform.io/intro/getting-started/change.html

     Destroy Infrastructure: https://www.terraform.io/intro/getting-started/destroy.html
 
