// This Bicep code deploys Azure Sentinel service - A Log Analytics Workspace (LAW) and a Solution named "Azure Snetinel" - with Parameteres and Variables

// Parameters

@description('Name of the Log Analytics Workspace used to agregate data for Sentinel solution')
param sentinelworkspaceName string

@description('Defines the location to deploy Log Analytics Workspace and Sentinel solution')
param location string = resourceGroup().location

@description('Pricing tier / SKU for the LAW')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param pricingTier string = 'PerGB2018'

@description('Number of days logs are retained. Workspaces in the legacy Free pricing tier can only have 7 days. Allowed values are per pricing plan. See pricing tiers documentation for details.')
@minValue(7)
@maxValue(730)
param dataRetention int = 90

@description('Tags to be applied - as per the Organization tagging policy')
param resourceTags object = {
  EnvironmentName: 'Test'
  CostCenter: '1000100'
  Team: 'SecOps'
  Application: 'Azure Sentinel'
}

// Variables
var uniqueWorkspace = '${location}-log-${sentinelworkspaceName}-${uniqueString(resourceGroup().id)}'     // Deriving unique workspace name using the input from user, a unique string generated using the resource group ID


// Azure resource declarations - LAW and Azure Sentinel solution

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: uniqueWorkspace          // A globally unique name
  location: location
  properties: {
    sku:{
      name: pricingTier
    }
    retentionInDays: dataRetention
  }
  tags:resourceTags
}

resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspace.name})'     //Bicep style implict dependency - we are deriving the name of this resource using the name property of LAW, so it is dependnet on the Workspace
  location: location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan:{
    name: 'SecurityInsights(${workspace.name})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  tags:resourceTags
}

// output workspaceNameOutput string = uniqueWorkspace
// output workspaceIdOutput string = workspace.properties.customerId
// output workspacekeyOutput string = workspace.listKeys().primarySharedKey
