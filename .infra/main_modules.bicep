param location string = 'northcentralus'
param storageName string = 'mystoragetestapp'
param namePrefix string = 'bgtest'
targetScope = 'resourceGroup'

module storage 'modules/storage.bicep' = {
  name: storageName
  params: {
    storageName: '${namePrefix}${storageName}'
    location: location
  }
}

module plan 'modules/servicePlan.bicep' = {
  name: '${namePrefix}-deploy-plan'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

module web 'modules/webApp.bicep' = {
  name: '${namePrefix}-deploy-website'
  params: {
    appPlanId: plan.outputs.planId
    namePrefix: namePrefix
    location: location
  }
}
