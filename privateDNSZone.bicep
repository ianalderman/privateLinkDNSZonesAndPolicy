param zoneName string

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
}

output privateZoneId string = privateZone.id
