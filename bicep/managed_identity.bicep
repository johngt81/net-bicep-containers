param location string = resourceGroup().location
param name string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}

output identityId string = managedIdentity.id
output principalId string = managedIdentity.properties.principalId
