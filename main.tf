data "azurerm_resource_group" "rg" {
  name = "fbarryRG"
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-nonprod-prf2026"
  resource_group_name = "rg-shared-prf2026"
}

data "azurerm_postgresql_flexible_server" "psql" {
  name                = "psql-fbarry-db"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_storage_account" "storage" {
  name                = "stfbarrynonprod"
  resource_group_name = data.azurerm_resource_group.rg.name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}


resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "ns-franck-barry"
    labels = {
      owner     = var.owner_tag
      component = "kubernetes-namespace"
    }
  }
}

resource "azurerm_redis_cache" "redis" {
  name                = "redis-fbarry-nonprod"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"

  tags = {
    owner     = var.owner_tag
    component = "cache-redis"
  }
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-fbarry-nonprod"
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  tags = {
    owner     = var.owner_tag
    component = "key-vault"
  }
}