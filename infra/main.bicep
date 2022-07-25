targetScope = 'subscription'

@minLength(1)
@maxLength(17)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

//var resourceToken = '${name}-${toLower(uniqueString(subscription().id, name, location))}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${name}-rg'
  location: location
  tags: {
    'azd-env-name': name
  }
}

@description('This module deploys a servicebus and functionapp configured together')
module serviceBusApp 'servicebus-FunctionApp.bicep' = {
  name: 'resources-${name}'
  scope: resourceGroup
  params: {
    location: location
    resNameSeed: name
    
    //App Specifc names for FunctionApp and Service Bus Queue
    appName: 'queueCode'
    ServiceBusQueueName: 'theQueue'
    
    //Nifty azd tag to make deploying to the right app easier
    AppTags: {
      'azd-service-name': 'functionapp'
    }
  }
}

output APP_WEB_BASE_URL string = serviceBusApp.outputs.ApplicationUrl
output APPINSIGHTS_INSTRUMENTATIONKEY string = serviceBusApp.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = serviceBusApp.outputs.APPINSIGHTS_CONNECTION_STRING
output AZURE_LOCATION string = location
