@description('The name seed for your application. Check outputs for the actual name and url')
param appName string
param webAppName string = 'app-${appName}-${uniqueString(resourceGroup().id, appName)}'

@description('Name of the web app host plan')
param hostingPlanName string = 'plan-${appName}'

@description('Restricts inbound traffic to your functionapp, to just from APIM')
param restrictTrafficToJustAPIM bool = false

param location string = resourceGroup().location

param WorkerRuntime string = 'dotnet'

param RuntimeVersion string = '~4'

param AppInsightsName string
param additionalAppSettings array = []
param tags object = {}

@description('An optional, additional User Assigned Identity name that can be leveraged for other auth scenarios')
param fnAppIdentityName string = ''

resource AppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: AppInsightsName
}

var storageAccountRawName = toLower('stor${appName}${uniqueString(resourceGroup().id, appName)}')
var storageAccountName = length(storageAccountRawName) > 24 ? substring(storageAccountRawName,0,23) : storageAccountRawName

var coreAppSettings = [
  {
    'name': 'APPINSIGHTS_INSTRUMENTATIONKEY'
    'value': AppInsights.properties.InstrumentationKey
  }
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
  {
    'name': 'FUNCTIONS_EXTENSION_VERSION'
    'value': RuntimeVersion
  }
  {
    'name': 'FUNCTIONS_WORKER_RUNTIME'
    'value': WorkerRuntime
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
  {
    name: 'PROJECT'
    value: repoPath
  }
]

var siteConfig = {
  appSettings: length(additionalAppSettings) == 0 ? coreAppSettings : concat(coreAppSettings,additionalAppSettings)
  ipSecurityRestrictions: restrictTrafficToJustAPIM ? [
    {
      priority: 200
      action: 'Allow'
      name: 'API Management'
      description: 'Isolates inbound traffic to just APIM'
    }
  ] : []
}

var identityJustSystemAssigned = {
  type: 'SystemAssigned'
}

var identityUserAndSystemAssigned = {
  type: 'SystemAssigned, UserAssigned' 
  userAssignedIdentities: {
    '${fnAppUai.id}': {}
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  kind: 'functionapp'
  tags: tags
  identity: !empty(fnAppIdentityName) ? identityUserAndSystemAssigned : identityJustSystemAssigned
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    siteConfig: siteConfig
    keyVaultReferenceIdentity: !empty(fnAppIdentityName) ? fnAppUai.id : 'SystemAssigned'
  }
}
output appUrl string = functionApp.properties.defaultHostName
output appName string = functionApp.name
output systemAssignedIdentityPrincipalId string = functionApp.identity.principalId

param deploymentSlotName string = 'staging'
param repoBranchStaging string = ''
// resource slot 'Microsoft.Web/sites/slots@2021-02-01' = if (!empty(deploymentSlotName)) {
//   name: deploymentSlotName
//   parent: functionApp
//   location: location
//   properties:{
//     siteConfig: siteConfig
//     enabled: true
//     serverFarmId: hostingPlan.id
//   }

//   resource slotCodeDeploy 'sourcecontrols@2021-02-01' = if (!empty(deploymentSlotName) && !empty(repoUrl) && !empty(repoBranchStaging)) {
//     name: 'web'
//     properties: {
//       repoUrl: repoUrl
//       branch: repoBranchStaging
//       isManualIntegration: true
//     }
//   }
// }

resource fnAppUai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (!empty(fnAppIdentityName)) {
  name: fnAppIdentityName
}

resource webAppConfig 'Microsoft.Web/sites/config@2019-08-01' = if (!empty(repoUrl)) {
  parent: functionApp
  name: 'web'
  properties: {
    scmType: 'ExternalGit'
  }
}

resource webAppLogging 'Microsoft.Web/sites/config@2021-02-01' = {
  parent: functionApp
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInDays: 1
        retentionInMb: 25
      }
    }
  }
}

param repoUrl string = ''
param repoPath string = ''
param repoBranchProduction string = 'main'
resource codeDeploy 'Microsoft.Web/sites/sourcecontrols@2021-01-15' = if (!empty(repoUrl) && !empty(repoBranchProduction)) {
  parent: functionApp
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: repoBranchProduction
    isManualIntegration: true
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}
output hostingPlanName string = hostingPlan.name
