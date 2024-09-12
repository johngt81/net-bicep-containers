param env string = 'dev'

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the container app.')
param containerAppName string = 'app-productsapi-${env}-003'

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'env-productsapi-${env}-003'

@description('Specifies the name of the log analytics workspace.')
param containerAppLogAnalyticsName string = 'log-productsapi-${env}-003'

@description('Specifies the docker container image to deploy.')
param containerImage string = 'mcr.microsoft.com/appsvc/staticsite:latest'

@description('Specifies the container port.')
param targetPort int = 80

@description('Number of CPU cores the container can use. Can be with a maximum of two decimals.')
@allowed([
  '0.25'
  '0.5'
  '0.75'
  '1'
  '1.25'
  '1.5'
  '1.75'
  '2'
])
param cpuCore string = '0.5'

@description('Amount of memory (in gibibytes, GiB) allocated to the container up to 4GiB. Can be with a maximum of two decimals. Ratio with CPU cores must be equal to 2.')
@allowed([
  '0.5'
  '1'
  '1.5'
  '2'
  '3'
  '3.5'
  '4'
])
param memorySize string = '1'

@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplicas int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplicas int = 3

param tenantId string = subscription().tenantId

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: containerAppLogAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: containerAppEnvName
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// module managedIdentity 'managed_identity.bicep' = {
//   name: 'identity-productsapi3'
//   params: {
//     location: location
//     name: 'identity-productsapi3'
//   }
// }
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: 'identity-productsapi3'
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-productsapi3'
  // location: location
  // properties: {
  //   tenantId: tenantId
  //   accessPolicies: [
  //     {
  //       tenantId: tenantId
  //       objectId: managedIdentity.outputs.principalId
  //       permissions: {
  //         secrets: [
  //           'list'
  //           'get'
  //         ]
  //       }
  //     }
  //   ]
  //   sku: {
  //     name: 'standard'
  //     family: 'A'
  //   }
  // }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentity.name}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: 'test'
          // value: 'https://${keyVault.name}.vault.azure.net/secrets/test'
          keyVaultUrl: 'https://${keyVault.name}.vault.azure.net/secrets/test'
          identity: managedIdentity.name
          // identity: managedIdentity.name
          // value: '@Microsoft.KeyVault(VaultName=${keyVault.name};SecretName=mySecret)'
        }
      ]
      activeRevisionsMode: 'Multiple'
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: containerAppName
          image: containerImage
          env: [
            {
              name: 'MY_SECRET'
              secretRef: 'test'
            }
          ]
          resources: {
            cpu: json(cpuCore)
            memory: '${memorySize}Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
