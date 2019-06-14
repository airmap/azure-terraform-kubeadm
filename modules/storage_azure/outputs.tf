output "kubernetes_blob_endpoint" {
  value = "${azurerm_storage_account.main.primary_blob_endpoint}${azurerm_storage_container.kubernetes.name}"
}

output "sas_string" {
  value = data.azurerm_storage_account_sas.main.sas
}

