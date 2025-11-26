provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "Set", "List", "Delete"]
  }
}

resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "pg_password" {
  name         = "postgres-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "pg_username" {
  name         = "postgres-username"
  value        = var.postgres_admin
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "pg_dbname" {
  name         = "postgres-dbname"
  value        = var.postgres_db_name
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = var.postgres_server_name
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  administrator_login    = var.postgres_admin
  administrator_password = random_password.postgres_password.result
  version                = "15"
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768

  authentication {
    password_auth_enabled = true
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    environment = "dev"
  }
}

resource "azurerm_postgresql_flexible_server_database" "pgdb" {
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.pg.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name                = "system"
    node_count          = 1
    vm_size             = "Standard_B2ps_v2"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = var.kubernetes_version
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "swiss_dev" {
  metadata {
    name = "swiss-dev"
  }
}