terraform {
  required_version = ">= 1.3.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.3.0"
    }
  }
}
