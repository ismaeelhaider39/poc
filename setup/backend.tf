# terraform {
#   backend "azurerm" {
#     resource_group_name  = "Nouman-RG"
#     storage_account_name = "tfstaccfinz"
#     container_name       = "terragrunt-saqib"
#     key                  =  "terraform.tfstate"
#   }
# }