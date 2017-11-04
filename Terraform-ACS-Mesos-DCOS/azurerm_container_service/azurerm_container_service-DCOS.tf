resource "azurerm_resource_group" "test" {
  name     = "demo-acs-dcos-tf-eastus-rg"
  location = "East US"
}

resource "azurerm_container_service" "test" {
  name                   = "acctestcontservice1"
  location               = "${azurerm_resource_group.test.location}"
  resource_group_name    = "${azurerm_resource_group.test.name}"
  orchestration_platform = "DCOS"

  master_profile {
    count      = 1
    dns_prefix = "acctestmaster1-{snip}"
  }

  linux_profile {
    admin_username = "acctestuser1"

    ssh_key {
      key_data = "ssh-rsa AAAA{snip}V1CR terraform@demo.tld"
    }
  }

  agent_pool_profile {
    name       = "default"
    count      = 1
    dns_prefix = "acctestagent1-{snip}"
    vm_size    = "Standard_A0"
  }

  diagnostics_profile {
    enabled = false
  }

  tags {
    Environment = "Demo"
  }
}