Lab 07 terraform.tfvars and variables.tf

terraform.tfvars is a special file in Terraform where we can store values for the variables we define in variables.tf.
Think of it like a "settings file" that tells Terraform what values to use.

variables.tf is like the blueprint for our Terraform configuration. It defines what inputs your Terraform scripts expect. Using it makes your code flexible, reusable, and easier to manage.
It is very useful as we can define inputs once in a single file. Instead of hardcoding values in our resources, we can define variables in one place. It separate code from data

In this lab, we will define variables in variables.tf file and store the values for those variables in terraform.tfvars file.

Folder Structure

tf-azure-project/
├── backend.tf
├── providers.tf
├── rg.tf
├── terraform.tfvars
└── store.tf

Providers.tf =>

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>4.36.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features { }
}
 
Backend.tf =>

terraform {
    backend "azurerm" {
    resource_group_name   = "rg-remotebackend"
    storage_account_name  = "tfstateprod12343" 
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}
 
Variables.tf =>

variable "rgname" {
  description = "Name of Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_name" {
  description = "Name of Storage Account"
  type        = string
}

variable "container_name" {
  description = "Name of Blob Container"
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account Tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for storage account (LRS, GRS)"
  type        = string
  default     = "LRS"
}

variable "environment" {
  description = "Environment tag for resources (dev, prod, staging)"
  type        = string
  default     = "staging"
}

variable "container_access_type" {
  description = "Access type for blob container (private, blob, container)"
  type        = string
  default     = "private"
}

variable "blob_name" {
  description = "Name of the blob file"
  type        = string
  default     = "example.txt"
}

variable "blob_type" {
  description = "Type of blob: Block, Append, or Page"
  type        = string
  default     = "Block"
}

variable "blob_source" {
  description = "Local path of the file to upload"
  type        = string
  default     = "C:/<path>"
}

Terraform.tfvars =>

rgname                           = "rg-prod"
location                         = "UK West"
storage_account_name             = "prodazstore101"
container_name                   = "storecontent"
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"
environment                      = "staging"
container_access_type            = "private"
blob_name                        = "data.txt"
blob_type                        = "Block"
blob_source                      = "C:/<path>"
 
Rg.tf =>

resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.location
}
 
Store.tf =>

resource "azurerm_storage_account" "azstore" {
name = var.storage_account_name
resource_group_name = var.rgname
location = var.location
account_tier = var.storage_account_tier
account_replication_type = var.storage_account_replication_type
tags = {
    environment = var.environment
}
}

resource "azurerm_storage_container" "storecontainer" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.azstore.id
  container_access_type = var.container_access_type
}

resource "azurerm_storage_blob" "storeblob" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.azstore.name
  storage_container_name = azurerm_storage_container.storecontainer.name
  type                   = var.blob_type
  source                 = var.blob_source
}
 
