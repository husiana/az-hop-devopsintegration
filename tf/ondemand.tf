resource "azurerm_public_ip" "ondemand-pip" {
  name                = "ondemand-pip"
  location            = local.create_rg ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  resource_group_name = local.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  allocation_method   = "Static"
  domain_name_label   = "ondemand${random_string.resource_postfix.result}"
}

resource "azurerm_network_interface" "ondemand-nic" {
  name                = "ondemand-nic"
  location            = local.create_rg ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  resource_group_name = local.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.create_vnet ? azurerm_subnet.frontend[0].id : data.azurerm_subnet.frontend[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ondemand-pip.id
  }
}

resource "azurerm_linux_virtual_machine" "ondemand" {
  name                = "ondemand"
  location            = local.create_rg ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  resource_group_name = local.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  size                = try(local.configuration_yml["ondemand"].vm_size, "Standard_D4s_v3")
  admin_username      = local.admin_username
  network_interface_ids = [
    azurerm_network_interface.ondemand-nic.id,
  ]

  admin_ssh_key {
    username   = local.admin_username
    public_key = tls_private_key.internal.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
}
