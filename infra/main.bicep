targetScope = 'subscription'

@minLength(1)
@maxLength(17)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

var resourceToken = '${name}-${toLower(uniqueString(subscription().id, name, location))}'

var tags = {
  'azd-env-name': name
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

@description('This module deploys a servicebus and functionapp configured together')
module serviceBusApp 'servicebus-FunctionApp.bicep' = {
  name: 'resources-${resourceToken}'
  scope: resourceGroup
  params: {
    location: location
    resNameSeed: resourceToken
    webAppName: 'app-${resourceToken}'
    
    appName: 'queueCode'
    ServiceBusQueueName: 'theQueue'
  }
}

output APPINSIGHTS_INSTRUMENTATIONKEY string = serviceBusApp.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = serviceBusApp.outputs.APPINSIGHTS_CONNECTION_STRING
output AZURE_LOCATION string = location
