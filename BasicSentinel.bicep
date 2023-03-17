// This Bicep code deploys Azure Sentinel service - A Log Analytics Workspace (LAW) and a Solution named "Azure Snetinel" - without Parameters

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'TestLAWforSentinel'          // A globally unique name
  location: resourceGroup().location
  properties: {
    sku:{
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspace.name})'     //Bicep style implict dependency - this resource is dependnet in workspace
  location: resourceGroup().location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan:{
    name: 'SecurityInsights(${workspace.name})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'

  }
}
