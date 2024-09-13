param location string = resourceGroup().location

param env string = 'dev'

@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'crweatherapi${env}003'

param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

module managedIdentity 'managed_identity.bicep' = {
  name: 'identity-weatherapi3'
  params: {
    location: location
    name: 'identity-weatherapi3'
  }
}

module keyVault 'keyvault.bicep' = {
  name: 'kv-weatherapi3'
  params: {
    location: location
    keyVaultName: 'kv-weatherapi3'
    acrUsername: acrResource.listCredentials().username
    acrPassword: acrResource.listCredentials().passwords[0].value
    principalId: managedIdentity.outputs.principalId
  }
}
