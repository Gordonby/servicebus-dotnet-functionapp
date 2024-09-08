@description('The name seed for all your other resources.')
param resNameSeed string

@description('The Log Analytics retention period')
param retentionInDays int = 30

param location string = resourceGroup().location

var log_name = 'log-${resNameSeed}'

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: log_name
  location: location
  properties: {
    retentionInDays: retentionInDays
  }
}
output id string = log.id
