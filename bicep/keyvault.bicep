@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location
@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv-productsapi'

param tenantId string = subscription().tenantId

module managedIdentity 'managed_identity.bicep' = {
  name: 'identity-productsapi'
  params: {
    location: location
    name: 'identity-productsapi'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  dependsOn: [
    managedIdentity
  ]
  properties: {
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: managedIdentity.outputs.principalId
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

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'mySecret'
  properties: {
    value: 'mySecretValue'
  }
}

output keyVaultName string = keyVault.name
