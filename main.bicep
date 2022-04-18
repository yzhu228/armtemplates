targetScope = 'subscription'

param vnetRgName string
param vmRgName string

@secure()
param vmAdminPassword string

param location string = deployment().location

param vmConfig object

resource vnetRg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: vnetRgName
}

resource vmRg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: vmRgName
}

module vmModule 'windowsvm.bicep' = {
  name: '${vmConfig.vmHostName}Deployment'
  scope: vmRg

  params: {
    vmHostName: vmConfig.vmHostName
    vnetName: vmConfig.vnetName
    subnetName: vmConfig.subnetName
    vnetRg: vnetRgName
    location: location
    adminUsername: vmConfig.adminUsername
    adminPassword: vmAdminPassword
  }
}

module nsgRuleModule 'NsgRdpRules.bicep' = {
  name: '${vnetRgName}NsgRuleDeployment'
  scope: vnetRg
  params: {
    subnetName: vmConfig.subnetName
  }
}
