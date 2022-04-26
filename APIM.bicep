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

var testerProductName = 'Tester'

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

resource TesterProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: testerProductName
  parent: apiManagementInstance
  properties: {
    displayName: 'Tester Product'
    description: 'My first example product'
    subscriptionRequired: true
    state: 'published'
  }
}

resource testerProductGroup 'Microsoft.ApiManagement/service/products/groups@2021-08-01' = {
  name: 'Guests'
  parent: TesterProduct
}

resource adminProductGroup 'Microsoft.ApiManagement/service/products/groups@2021-08-01' = {
  name: 'Administrators'
  parent: TesterProduct
}

resource devProductGroup 'Microsoft.ApiManagement/service/products/groups@2021-08-01' = {
  name: 'Developers'
  parent: TesterProduct
}

module TesterApiModule 'apis/TesterApi.bicep' = {
  name: 'TesterApiDeployment'
  dependsOn: [
    apiManagementInstance
    TesterProduct
  ]
  params: {
    apimName: apiManagementServiceName
    productName: testerProductName
  }
}

module TesterFuncApiModule 'apis/TesterFunctionApi.bicep' = {
  name: 'TesterFunctionApiDeployment'
  params: {
    apimName: apiManagementServiceName
    funcAppName: 'testerapi1922'
  }
}
