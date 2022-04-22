targetScope = 'subscription'

param resourceGroupName string
param location string = deployment().location

param vnets array

resource resGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module vnetModule 'vnet.bicep' = [for v in vnets: {
  scope: resGroup
  name: '${v.name}Deployment'
  params: {
    vnetName: v.name
    addresses: v.addresses
    subnets: v.subnets
    location: location
  }
}]
