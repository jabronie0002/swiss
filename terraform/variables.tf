variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "West US"
  description = "Azure region"
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
}

variable "postgres_server_name" {
  type        = string
  description = "Name of the PostgreSQL Flexible Server"
}

variable "postgres_admin" {
  type        = string
  default     = "pgadmin"
  description = "PostgreSQL admin username"
}

variable "postgres_db_name" {
  type        = string
  default     = "swissdb"
  description = "Name of the PostgreSQL database"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.34.0" # Adjust to latest supported version
}