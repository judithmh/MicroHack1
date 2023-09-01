targetScope = 'subscription'

@description('Object ID of the current user (az ad signed-in-user show --query id)')
param currentUserObjectId string

@description('Prefix for multiple deployments per subscription')
param prefix string = 'mh'

@description('The Number of deployments per subscription')
param deploymentCount int = 1

@description('Azure region for the deployment')
@allowed([
  'West Europe'
  'North Europe'
  'East US'
  'East US 2'
  'Southeast Asia'
  'East Asia'
  'Germany West Central'
])
param location string

@description('Source Resouce Groups.')
resource sourceRg 'Microsoft.Resources/resourceGroups@2021-01-01' = [for i in range(0, deploymentCount): {
  name: '${prefix}${(i+1)}-source-rg'
  location: location
}]

@description('Source Module to deploy initial demo resources for migration')
module source 'source.bicep' = [for i in range(0, deploymentCount):  {
  name: '${prefix}${(i+1)}-sourceModule'
  scope: sourceRg[i]
  params: {
    location: location
    currentUserObjectId: currentUserObjectId
    prefix: prefix
    deployment: (i+1)
  }
}]

@description('Destination Resouce Groups.')
resource destinationRg 'Microsoft.Resources/resourceGroups@2021-01-01' = [for i in range(0, deploymentCount): {
  name: '${prefix}${(i+1)}-destination-rg'
  location: location
}]

@description('Destination Module to deploy the destination resources')
module destination 'destination.bicep' = [for i in range(0, deploymentCount): {
  name: '${prefix}${(i+1)}-destinationModule'
  scope: destinationRg[i]
  params: {
    location: location
    prefix: prefix
    deployment: (i+1)
  }
}]
