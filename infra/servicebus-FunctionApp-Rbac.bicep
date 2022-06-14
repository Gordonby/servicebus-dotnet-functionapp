param ServiceBusNamespaceName string
param PrincipalId string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: ServiceBusNamespaceName
}

// --------------------RBAC-------------------
var serviceBusDataReceiver = resourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
resource rbacReceiveMessage 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(serviceBusDataReceiver, ServiceBusNamespaceName, PrincipalId)
  scope: serviceBusNamespace
  properties: {
    principalId: PrincipalId
    roleDefinitionId: serviceBusDataReceiver
  }
}

var serviceBusDataSender = resourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
resource rbacSendMessage 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(serviceBusDataSender, ServiceBusNamespaceName, PrincipalId)
  scope: serviceBusNamespace
  properties: {
    principalId: PrincipalId
    roleDefinitionId: serviceBusDataSender
  }
}
