terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}  # This is required by the azurerm provider
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  sensitive   = true
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "samurai"
  location = "West Europe"
}

# SQL Server (Updated resource type: azurerm_mssql_server)
resource "azurerm_mssql_server" "example" {
  name                         = "example-sql-server"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_loterrain      = "sqladminuser"
  administrator_login_password = "YourP@ssword123"  # Use a secure password
}

# SQL Database (Updated resource type: azurerm_mssql_database, Free Tier: Basic)
resource "azurerm_mssql_database" "example" {
  name          = "example-sql-database"
  server_id     = azurerm_mssql_server.example.id  # Use server_id instead of server_name
  sku_name      = "Basic"  # Using the Basic tier for free
  collation     = "SQL_Latin1_General_CP1_CI_AS"
}

# Optional: Firewall rule to allow access from a specific IP (Updated resource type: azurerm_mssql_firewall_rule)
resource "azurerm_mssql_firewall_rule" "example" {
  name        = "example-firewall-rule"
  server_id   = azurerm_mssql_server.example.id  # Use server_id instead of server_name
  start_ip_address = "0.0.0.0"  # Replace with your IP address or range
  end_ip_address   = "255.255.255.255"  # Replace with your IP address or range
}