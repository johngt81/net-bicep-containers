param location string = resourceGroup().location
param env string = 'dev'
param sku string = 'B1'
var appName = 'app-productsapi-${env}-001'

module managedIdentity 'identity.bicep' = {
  name: 'acrIdentity'
  params: {
    location: location
    name: 'acrIdentity'
  }
}
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentity.name}': {}
    }
  }
  tags: {}
  properties: {
    siteConfig: {
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentity.outputs.managedIdentityId
      appSettings: []
      linuxFxVersion: 'mcr.microsoft.com/appsvc/staticsite:latest'
    }
    serverFarmId: appServicePlan.id
  }
}
