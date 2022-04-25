param vnets array
param location string = resourceGroup().location

@secure()
param winvmAdminPassword string

param hasPublicIpAddress bool = false

resource artifactsRg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'az104lt'
  scope: subscription()
}

resource artfactsStorage 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: 'yzhuartifacts'
  scope: artifactsRg
}

module vnetModule 'vnet.bicep' = [for v in vnets: {
  name: '${v.name}Deployment'
  params: {
    vnetName: v.name
    addresses: v.addresses
    subnets: v.subnets
    location: location
  }
}]

module winVmModule 'windowsvm.bicep' = [for v in vnets[0].subnets: {
  name: '${v.name}-vm-Deployment'
  dependsOn: [
    vnetModule
  ]
  params: {
    adminPassword: winvmAdminPassword
    adminUsername: 'yzhu'
    subnetName: v.name
    vmHostName: '${v.name}vm'
    vnetName: vnets[0].name
    location: location
    scriptStorageEndpoint: artfactsStorage.properties.primaryEndpoints.blob
    sku: 'Standard_D2_v3'
    installIIS: true
    hasPublicIpAddress: hasPublicIpAddress
  }
}]
