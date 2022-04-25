param location string = resourceGroup().location

param vnets array
@secure()
param winvmAdminPassword string

param hasPublicIpAddress bool = true

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

module winVmModule 'windowsvm.bicep' = [for v in vnets: {
  name: '${v.name}-vm-Deployment'
  dependsOn: [
    vnetModule
  ]
  params: {
    adminPassword: winvmAdminPassword
    adminUsername: 'yzhu'
    subnetName: v.subnets[0].name
    vmHostName: '${v.name}vm'
    vnetName: v.name
    location: location
    scriptStorageEndpoint: artfactsStorage.properties.primaryEndpoints.blob
    sku: v.name == 'onpremise' ? 'Standard_D2_v3' : 'Standard_A2_v2'
    installIIS: v.name != 'onpremise'
    hasPublicIpAddress: v.name != 'onpremise' ? hasPublicIpAddress : true
  }
}]
