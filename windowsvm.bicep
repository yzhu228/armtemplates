param vmHostName string

param vnetName string
param subnetName string
param vnetRg string = resourceGroup().name

param adminUsername string
@secure()
param adminPassword string

@allowed([
  'Standard_A2_v2'
])
param sku string = 'Standard_A2_v2'

param location string = resourceGroup().location

var storageName = toLower('yz${vmHostName}storage')
var nicName = '${vmHostName}-nic'
var ipconfigName = '${vmHostName}-ipconfig'
var publicIpName = '${vmHostName}-pip'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIpName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'yz-${vmHostName}'
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipconfigName
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
}

// resource networkSecurityGroupSecurityRule 'Microsoft.Network/networkSecurityGroups/securityRules@2019-11-01' = {
//   name: 'networkSecurityGroup/name'
//   properties: {
//     description: 'description'
//     protocol: '*'
//     sourcePortRange: 'sourcePortRange'
//     destinationPortRange: 'destinationPortRange'
//     sourceAddressPrefix: 'sourceAddressPrefix'
//     destinationAddressPrefix: 'destinationAddressPrefix'
//     access: 'Allow'
//     priority: 100
//     direction: 'Inbound'
//   }
// }

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmHostName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: sku
    }
    osProfile: {
      computerName: vmHostName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmHostName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageaccount.properties.primaryEndpoints.blob
      }
    }
  }
}
