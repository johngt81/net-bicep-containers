param location string = 'northcentralus'
param namePrefix string
param appPlanId string

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: '${namePrefix}-site'
  location: location
  properties: {
    serverFarmId: appPlanId
    httpsOnly: true
  }
}

output siteUrl string = webApplication.properties.hostNames[0]
