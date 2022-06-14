targetScope = 'subscription'

@minLength(1)
@maxLength(17)
@description('Prefix for all resources, i.e. {name}storage')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${name}rg'
  location: location
}

@description('This module deploys a servicebus and functionapp configured together')
module serviceBusApp 'servicebus-FunctionApp.bicep' = {
  name: 'demoapp'
  scope: resourceGroup
  params: {
    location: location
    resNameSeed: 'demo'
    appName: 'queCode'
    ServiceBusQueueName: 'theQueue'
  }
}

output APPINSIGHTS_INSTRUMENTATIONKEY string = serviceBusApp.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = serviceBusApp.outputs.APPINSIGHTS_CONNECTION_STRING
output AZURE_LOCATION string = location
