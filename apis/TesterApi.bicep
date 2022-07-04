param apimName string
param productName string

var testerApisPolicy = loadTextContent('TesterApi.policy.xml')

resource TesterProduct 'Microsoft.ApiManagement/service/products@2021-08-01' existing = {
  name: productName
  parent: apimInstance
}
resource apimInstance 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource myTesterApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: 'tester-api'
  parent: TesterProduct
  dependsOn: [
    serviceTesterApi
  ]
}

resource serviceTesterApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'tester-api'
  parent: apimInstance
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

resource testerApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: serviceTesterApi
  properties: {
    value: testerApisPolicy
    format: 'xml'
  }
}

resource wipapiTestOperation 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  name: 'test'
  parent: serviceTesterApi
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
