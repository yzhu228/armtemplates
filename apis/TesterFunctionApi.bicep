param apimName string

resource apimInstance 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource serviceMyWipApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
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
