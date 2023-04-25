/*
  A single function app that has permissions to send/receive to a new Service Bus Queue.
*/

@description('The name seed for your functionapp. Check outputs for the actual name and url')
param appName string

@description('The name seed for all your other resources.')
param resNameSeed string

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('Needs to be unique as ends up as a public endpoint')
param webAppName string = 'app-${appName}-${uniqueString(resourceGroup().id, appName)}'

// --------------------Function App-------------------
@description('The full publicly accessible external Git(Hub) repo url')
param AppGitRepoUrl string = ''

@description('If the app code is in a subdirectory, specify the path here for KUDO')
param AppGitRepoPath string = ''

@description('The functionApp module supports slots, we bind a slot to a specific GitHub branch. This is for the production slot.')
param AppGitRepoProdBranch string = 'main'

//@description('The functionApp module supports slots, we bind a slot to a specific GitHub branch. This is for the staging slot.')
//param AppGitRepoStagingBranch string = ''

param AppTags object = {}

@description('This array will be appended to the AppSettings in the functionApp module.')
var ServiceBusAppSettings = [
  {
    name: 'ServiceBusConnection__fullyQualifiedNamespace'
    value: servicebus.outputs.serviceBusFqdn
  }
  {
    name: 'ServiceBusQueueName'
    value: servicebus.outputs.serviceBusQueueName
  }
]

@description('Creates a consumption based functionApp that is source-bound to a Git repo')
module functionApp 'foundationalModules/functionapp.bicep' = {
  name: 'functionApp-${appName}-${resNameSeed}'
  params: {
    location: location
    appName: appName
    webAppName: webAppName
    tags: AppTags
    AppInsightsName: appInsights.outputs.name
    repoUrl: AppGitRepoUrl
    repoPath: AppGitRepoPath
    repoBranchProduction: AppGitRepoProdBranch
    //repoBranchStaging: AppGitRepoStagingBranch
    //deploymentSlotName: ''
    additionalAppSettings: ServiceBusAppSettings
  }
}

@description('The raw function app url')
output ApplicationUrl string = 'https://${functionApp.outputs.appUrl}' 

// -------------------Service Bus---------------------
@description('The name of the ServiceBus Queue to create in the ServiceBus namespace')
param ServiceBusQueueName string
module servicebus 'foundationalModules/servicebus-queue.bicep' = {
  name: 'servicebus-${resNameSeed}'
  params: {
    serviceBusQueueName: ServiceBusQueueName
    serviceBusNamespaceName: resNameSeed
    location: location
  }
}

// --------------------App Insights-------------------
module appInsights 'foundationalModules/appinsights.bicep' = {
  name: 'appinsights-${resNameSeed}'
  params: {
    appName: webAppName
    logAnalyticsId: logAnalyticsResourceId
    location: location
  }
}
output APPINSIGHTS_NAME string = appInsights.outputs.name
output APPINSIGHTS_INSTRUMENTATIONKEY string = appInsights.outputs.instrumentationKey
output APPINSIGHTS_CONNECTION_STRING string = appInsights.outputs.connectionString

// --------------------Log Analytics-------------------
@description('If you have an existing log analytics workspace in this region that you prefer, set the full resourceId here')
param centralLogAnalyticsId string = ''
module log 'foundationalModules/loganalytics.bicep' = if(empty(centralLogAnalyticsId)) {
  name: 'log-${resNameSeed}'
  params: {
    resNameSeed: resNameSeed
    retentionInDays: 30
    location: location
  }
}
var logAnalyticsResourceId =  !empty(centralLogAnalyticsId) ? centralLogAnalyticsId : log.outputs.id

module rbac 'servicebus-FunctionApp-Rbac.bicep' = {
  name: 'rbac-${resNameSeed}'
  params: {
    ServiceBusNamespaceName: servicebus.outputs.serviceBusNamespace
    PrincipalId: functionApp.outputs.systemAssignedIdentityPrincipalId
  }
}
