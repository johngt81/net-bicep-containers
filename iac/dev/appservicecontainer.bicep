param location string = resourceGroup().location
param sku string = 'B1'
param env string = 'dev'
var appName = 'app-productsapi-${env}-001'

// module registry 'container.bicep' = {
//   name: 'productregistry'
//   params: {
//     env: env
//     acrName: 'crproductsapi${env}001'
//     acrSku: 'Basic'
//     location: location
//   }
// }

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
    // httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
      appSettings: []
      // appSettings: [
      //   {
      //     name: 'DOCKER_REGISTRY_SERVER_URL'
      //     value: registry.outputs.loginServer
      //   }
      // {
      //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
      //   value: registryUsername
      // }
      // {
      //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
      //   value: registryPassword
      // }
      //   {
      //     name: 'WEBSITES_PORT'
      //     value: '80'
      //   }
      // ]
    }
  }
}

output siteUrl string = webApplication.properties.hostNames[0]
