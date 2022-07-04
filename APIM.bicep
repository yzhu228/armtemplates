@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The email address of the owner of the service')
param publisherEmail string

@description('The name of the owner of the service')
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Consumption'
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

  resource managementApi 'tenant' = {
    name: 'access'
    properties: {
      enabled: true
    }
  }
}

resource starterProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'Starter'
  parent: apiManagementInstance
  properties: {
    displayName: 'Starter'
    state: 'notPublished'
  }
}

resource unlimitedProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'Unlimited'
  parent: apiManagementInstance
  properties: {
    displayName: 'Unlimited'
    state: 'notPublished'
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

resource productDefaultSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  name: 'Def-${testerProductName}'
  parent: apiManagementInstance
  properties: {
    scope: TesterProduct.id
    displayName: 'Default-${testerProductName}'
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'apim-laworkspace'
  location: location
  properties: {
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// App Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'apim-ain'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// module TesterApiModule 'apis/TesterApi.bicep' = {
//   name: 'TesterApiDeployment'
//   dependsOn: [
//     apiManagementInstance
//     TesterProduct
//   ]
//   params: {
//     apimName: apiManagementServiceName
//     productName: testerProductName
//   }
// }

// module TesterFuncApiModule 'apis/TesterFunctionApi.bicep' = {
//   name: 'TesterFunctionApiDeployment'
//   dependsOn: [
//     apiManagementInstance
//     TesterProduct
//   ]
//   params: {
//     apimName: apiManagementServiceName
//     funcSiteName: siteName
//     funcAppName: funcName
//   }
// }
