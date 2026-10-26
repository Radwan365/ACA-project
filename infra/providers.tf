terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# subscription_id comes from the ARM_SUBSCRIPTION_ID environment variable (required since azurerm v4)
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  resource_provider_registrations = "none"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
