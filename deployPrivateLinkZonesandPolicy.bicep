
targetScope = 'subscription'

var privateLinkZonesToConfigure = [
  {
    groupId: 'blob'
    zoneName: 'privatelink.blob.core.windows.net'
  }
  {
    groupId: 'sqlServer'
    zoneName: 'privatelink.database.windows.net'
  }
]

var dnsZoneSubscriptionId = subscription().subscriptionId
var policySubscriptionId = subscription().subscriptionId

param dnsZoneResourceGroupName string
param dnsZoneResourceGroupLocation string = 'northeurope'

resource dnsZoneResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: dnsZoneResourceGroupName
  location: dnsZoneResourceGroupLocation
}

module privateZone './privateDNSZone.bicep' = [for subResource in privateLinkZonesToConfigure: {
  name: 'deployPrivateLinkDNSZoneFor${subResource.groupId}'
  params: {
    zoneName: subResource.zoneName
  }
  scope: resourceGroup(dnsZoneSubscriptionId, dnsZoneResourceGroup.name)
}]

module privateLinkDNSPolicy 'privateLinkPolicy.bicep' = [for subResource in privateLinkZonesToConfigure: {
  scope: subscription(policySubscriptionId)
  name: 'deployPrivateLinkDNSPolicyFor${subResource.groupId}'
  params: {
    groupId: subResource.groupId
  }
}]

resource privateLinkPolicyInitative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'Private Link DNS Configuration'
  properties: {
    policyType: 'Custom'
    policyDefinitions: [for i in range(0,length(privateLinkZonesToConfigure)): {
      policyDefinitionId: privateLinkDNSPolicy[i].outputs.privateLinkPolicyId
      policyDefinitionReferenceId: 'DINE Private Link DNS Entry for ${privateLinkZonesToConfigure[i].groupId}'
      parameters: {
        privateDnsZoneId: {
          value: privateZone[i].outputs.privateZoneId
        }
      }
    }]
  }
}
