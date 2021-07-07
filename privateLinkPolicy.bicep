targetScope = 'subscription'

param groupId string

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'dine-dns-zone-plink-${groupId}'
  properties: {
    displayName: 'Deploy if Not Exists DNS Zone for ${groupId} Private Link support'
    description: 'Ensures that Private Link DNS records are lifecycle managed along with their associated ${groupId} resource.'
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Network - DNS'
    }

    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/privateEndpoints'
          }
          {
            count: {
              field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
              where: {
                field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
                equals: groupId
              }
            }
            greaterOrEquals: 1
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups/privateDnsZoneConfigs[*].privateDnsZoneId'
                equals: '[parameters(\'privateDnsZoneId\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  privateDnsZoneId: {
                    type: 'string'
                  }
                  privateEndpointName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                resources: [
                  {
                    name: '[concat(parameters(\'privateEndpointName\'), \'/deployedByPolicy\')]'
                    type: 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups'
                    apiVersion: '2020-03-01'
                    location: '[parameters(\'location\')]'
                    properties: {
                      privateDnsZoneConfigs: [
                        {
                          name: '${groupId}-privateDnsZone'
                          properties: {
                            privateDnsZoneId: '[parameters(\'privateDnsZoneId\')]'
                          }
                        }
                      ]
                    }
                  }
                ]
              }
              parameters: {
                privateDnsZoneId: {
                  value: '[parameters(\'privateDnsZoneId\')]'
                }
                privateEndpointName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
    parameters: {
      privateDnsZoneId: {
        type: 'String'
        metadata: {
          displayName: 'privateDnsZoneId'
          strongType: 'Microsoft.Network/privateDnsZones'
        }
      }
    }
  }
}

output privateLinkPolicyId string = policy.id
