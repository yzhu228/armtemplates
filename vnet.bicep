param vnetName string

@description('''
[
  '10.90.0.0/16'
]
''')
param addresses array

@description('''
[
  {
    name: 'subnet1'
    addressSpace: '10.90.1.0/24'
  }
]
''')
param subnets array

param location string = resourceGroup().location

resource vnetGroup 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addresses
    }
    subnets: [for sn in subnets: {
      name: sn.name
      properties: {
        addressPrefix: sn.addressSpace
      }
    }]
  }
}
