data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "rg" {
  name = "fbarryRG"
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-nonprod-prf2026"
  resource_group_name = "rg-shared-prf2026"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-fbarry-nonprod"
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  tags = {
    owner     = "franck.barry"
    component = "key-vault"
  }
}

