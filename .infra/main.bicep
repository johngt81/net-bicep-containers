param location string = resourceGroup().location
param storageName string = 'space${uniqueString(resourceGroup().id)}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'xyz${storageName}'
  location: location
  sku: {
    name: 'F1'
  }
}

resource webApplication 'Microsoft.Web/sites@2023-12-01' = {
  name: 'zed${storageName}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
