@description('Function app name')
param funcName string

resource funcapp 'Microsoft.Web/sites@2021-03-01' existing = {
  name: funcName
}

output FunctionApp object = {
  FuncAppId: funcapp.id
  FunctionKey: listkeys(concat(funcapp.id, '/host/default'), '2021-03-01').functionKeys.default
}
