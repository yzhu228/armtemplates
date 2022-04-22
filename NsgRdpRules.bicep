param subnetName string

resource vnetNsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: '${subnetName}-nsg'
}

resource networkSecurityGroupSecurityRule 'Microsoft.Network/networkSecurityGroups/securityRules@2019-11-01' = {
  name: 'Port_RDP'
  parent: vnetNsg
  properties: {
    description: 'RDP port'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
  }
}
