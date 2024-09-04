param namePrefix string
param location string = resourceGroup().location
param sku string = 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${namePrefix}-website'
  location: location
  sku: {
    name: sku
  }
}

output planId string = appServicePlan.id
