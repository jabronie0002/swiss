output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}