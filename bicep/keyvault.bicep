@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location
@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv-productsapi3'
param tenantId string = subscription().tenantId
@secure()
param acrUsername string
@secure()
param acrPassword string
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource secretUsername 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'acrUsername'
  properties: {
    value: acrUsername
  }
}

resource secretPassword 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'acrPassword'
  properties: {
    value: acrPassword
  }
}

resource secretTest 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'test'
  properties: {
    value: 'Test Value'
  }
}

output keyVaultName string = keyVault.name
