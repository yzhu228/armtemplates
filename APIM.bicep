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

resource TesterProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'Tester'
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

resource myWipApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: 'tester-api'
  parent: TesterProduct
}

resource serviceMyWipApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'tester-api'
  parent: apiManagementInstance
  properties: {
    displayName: 'Tester API'
    path: 'tester'
    protocols: [
      'https'
    ]
    apiType: 'http'
    isCurrent: true
    subscriptionRequired: false
  }
}

resource wipapiTestOperation 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'test'
  parent: serviceMyWipApi
  properties: {
    urlTemplate: '/test'
    displayName: 'Test Call'
    method: 'GET'
    responses: [
      {
        statusCode: 200
        representations: [
          {
            contentType: 'application/json'
            examples: {
              'default': {
                'value': {
                  'sampleField': 'sampleValue'
                }
              }
            }
          }
        ]
        headers: []
      }
    ]
  }
}
