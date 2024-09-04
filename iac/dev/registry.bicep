param location string = resourceGroup().location
param env string = 'dev'
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'crproductsapi${env}001'
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}
@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
