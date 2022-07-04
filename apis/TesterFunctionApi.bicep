param apimName string
param funcSiteName string
param funcAppName string

var funcKeyName = '${funcSiteName}-key'
var policyContent = loadTextContent('TesterFunctionApi.policy.xml', 'utf-8')
var functionApiPolicy = replace(policyContent, '{funcAppName}', '${funcSiteName}')

resource funcSite 'Microsoft.Web/sites@2021-03-01' existing = {
  name: funcSiteName
}

resource funcApp 'Microsoft.Web/sites/functions@2021-03-01' existing = {
  name: funcAppName
  parent: funcSite
}

resource funcHostKey 'Microsoft.Web/sites/host/functionKeys@2021-03-01' = {
  name: '${funcSite.name}/default/apim-${apimName}'
  properties: {
    name: 'apim-${apimName}'
  }
}

resource apimInstance 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource kvAppKey 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: funcKeyName
  parent: apimInstance
  properties: {
    displayName: funcAppName
    value: funcHostKey.properties.value
    secret: true
    tags: [
      'key'
      'function'
      'auto'
      'arm'
    ]
  }
}

resource serviceBackend 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  name: funcSiteName
  parent: apimInstance
  dependsOn: [
    kvAppKey
  ]
  properties: {
    description: funcSiteName
    protocol: 'http'
    url: 'https://${funcSiteName}.azurewebsites.net/api'
    resourceId: 'https://management.azure.com${funcApp.id}'
    credentials: {
      header: {
        'x-functions-key': [
          '{{${funcKeyName}}}'
        ]
      }
    }
  }
}

resource funcAppApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'tester-func-api'
  parent: apimInstance
  dependsOn: [
    serviceBackend
  ]
  properties: {
    displayName: 'Tester Function API'
    path: 'functionapi'
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
  parent: funcAppApi
  properties: {
    value: functionApiPolicy
    format: 'xml'
  }
}

resource funcConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: funcSite
  properties: {
    apiManagementConfig: {
      id: funcAppApi.id
    }
  }
}
