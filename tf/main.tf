provider "azurerm" {
  features {}
}

resource "random_string" "random" {
  length = 8
  special = false
}

resource "random_string" "resource_postfix" {
  length = 6
  special = false
  upper = false
  lower = true
  number = true
}

resource "random_password" "password" {
  length = 16
  special = true
  # override_special = "_%@"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

resource "tls_private_key" "internal" {
  algorithm = "RSA"
  rsa_bits  = 2048 # This is the default
}

resource "local_file" "private_key" {
    content     = tls_private_key.internal.private_key_pem
    filename = "${var.admin_username}_id_rsa"
    file_permission = "0600"
}

resource "local_file" "public_key" {
    content     = tls_private_key.internal.public_key_openssh
    filename = "${var.admin_username}_id_rsa.pub"
    file_permission = "0644"
}