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


# Define variables
variable "resource_group_name" {
  default = "aks-resource-group"
}

variable "aks_cluster_name" {
  default = "aks-cluster"
}

variable "location" {
  default = "East US"
}


# Create a Resource Group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space        = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

# Create Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks-demo"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B1s"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}

# Corrected Output Block for kubeconfig
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}
