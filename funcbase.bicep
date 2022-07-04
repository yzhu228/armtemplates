targetScope = 'subscription'

@description('Resource group in which the function app resides')
param funcRgName string

@description('Function App name')
param funcName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: funcRgName
}

module funcAppModule 'func.bicep' = {
  scope: rg
  name: 'funAppMod'
  params: {
    funcName: funcName
  }
}

output FunctionAppId string = funcAppModule.outputs.FunctionApp.FuncAppId
output FunctionAppKey string = funcAppModule.outputs.FunctionApp.FunctionKey
