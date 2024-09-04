param location string = resourceGroup().location
param sku string = 'F1'
param env string = 'dev'
var appName = 'app-productsapi-${env}-001'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appName
  location: location
  sku: {
    name: sku
  }
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output siteUrl string = webApplication.properties.hostNames[0]
