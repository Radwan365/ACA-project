terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-tm-eus"
    storage_account_name = "sttfstatetmradwan"
    container_name       = "tfstate"
    key                  = "tm-dev.tfstate"
    use_azuread_auth     = true
  }
}
