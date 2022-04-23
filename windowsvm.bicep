param vmHostName string

param vnetName string
param subnetName string
param vnetRg string = resourceGroup().name

param adminUsername string
@secure()
param adminPassword string

param scriptStorageEndpoint string
param installIIS bool = false
param hasPublicIpAddress bool = true

@allowed([
  'Standard_A2_v2'
  'Standard_D2_v3'
])
param sku string = 'Standard_A2_v2'

param location string = resourceGroup().location

var normalizedHostName = replace(vmHostName, '-', '')

var storageName = toLower('yz${normalizedHostName}storage')
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

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (hasPublicIpAddress) {
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
          publicIPAddress: hasPublicIpAddress ? {
            id: publicIPAddress.id
          } : null
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
}

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

resource winCustomScript 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if (installIIS) {
  name: 'installIIS'
  parent: windowsVM
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      timestamp: 100
      commandToExecute: 'powershell -ExecutionPolicy Bypass -File InstallIIS.ps1'
    }
    protectedSettings: {
      fileUris: [
        '${scriptStorageEndpoint}data/InstallIIS.ps1'
      ]
    }
  }
}
