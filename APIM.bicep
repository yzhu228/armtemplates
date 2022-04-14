@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The email address of the owner of the service')
param publisherEmail string

@description('The name of the owner of the service')
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@maxValue(2)
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apiManagementServiceName
  location: location
  sku: {
    capacity: skuCount
    name: sku
  }
  properties: {
    virtualNetworkType: 'None'
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource myProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'MyProduct'
  parent: apiManagementInstance
  properties: {
    displayName: 'My First Product'
    description: 'My first example product'
    subscriptionRequired: false
  }
}

resource myWipApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: 'my-wip-api'
  parent: myProduct
}

resource serviceMyWipApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'my-wip-api'
  parent: apiManagementInstance
  properties: {
    displayName: 'My WIP Apis'
    path: 'mywipapi'
    protocols: [
      'https'
    ]
  }
}
