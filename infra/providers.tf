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

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-tm-eus"
    storage_account_name = "sttmtfstateeus"
    container_name       = "tfstate"
    key                  = "tm-dev.tfstate"
    use_azuread_auth     = true
  }
}

# subscription_id comes from the ARM_SUBSCRIPTION_ID environment variable (required since azurerm v4)
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
