@description('VNet in which this VM resides')
param vnetName string

@description('Subnet in which this VM resides')
param subnetName string

@description('ResourceGroup name to which this vnet belongs')
param vnetRg string = resourceGroup().name

@description('Admin username for the VM')
param adminUser string

@description('Admin user password')
@secure()
param adminPassword string

@description('Admin user public key')
param adminSSH string

@description('VM host name')
param hostName string

@description('VM\'s SKU')
@allowed([
  'Standard_B1s'
  'Standard_A2_v2'
  'Standard_D2_v2'
])
param hostSKU string = 'Standard_A2_v2'

param location string = resourceGroup().location

var dnsNamePrefix = 'yz'
var networkInterfaceName_var = '${hostName}-nic'
var publicIPAddressName_var = '${hostName}-PublicIP'
var virtualNetworkName = vnetName
var subnetName_var = subnetName
var vmStorageAccountName_var = toLower('${dnsNamePrefix}${hostName}storage')
var useSSH = (!empty(adminSSH))

resource vmStorageAccountName 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: vmStorageAccountName_var
  location: location
  tags: {
    displayName: '${hostName}storage account'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddressName_var
  location: location
  tags: {
    displayName: publicIPAddressName_var
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: '${dnsNamePrefix}-${hostName}'
    }
  }
}

resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaceName_var
  location: location
  tags: {
    displayName: networkInterfaceName_var
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: publicIPAddressName.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName_var)
          }
        }
      }
    ]
  }
}

resource hostName_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: hostName
  location: location
  tags: {
    displayName: hostName
  }
  properties: {
    hardwareProfile: {
      vmSize: hostSKU
    }
    osProfile: {
      computerName: hostName
      adminUsername: adminUser
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: useSSH
        ssh: {
          publicKeys: [
            {
              keyData: adminSSH
              path: '/home/${adminUser}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${hostName}-OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: vmStorageAccountName.properties.primaryEndpoints.blob
      }
    }
  }
}
