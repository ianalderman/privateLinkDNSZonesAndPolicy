# Private Link Azure DNS and Policy Support #

## Resources Provisioned ##
1. [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group) for Azure [Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone)
2. Azure [Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) to support [Private Link](https://docs.microsoft.com/en-us/azure/private-link/private-link-overview) [name resolution](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
3. [Azure Policies to deploy private link DNS entries](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale)
4. Policy [Initative](https://docs.microsoft.com/en-us/azure/governance/policy/samples/pattern-group-with-initiative) to wrap up the Azure policies into a single artifact

You will need to [assign](https://docs.microsoft.com/en-us/azure/governance/policy/overview#azure-policy-objects) the initiative / policies to make them effective

## Scope ##
As configured in this repo the policies / initiatives will be deployed to a subscription rather than a management group.  You can change this by setting the `targetscope` value appropriately in the Bicep files.  You would then need to add parameters for the management group name / subscription Id.

## Managing the Services configured ##
`privateLinkZonesToConfigure` contains a mapping of [Private Link Sub Resources and DNS Names](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns) that we wish to provision through the deployment.  In the example below we can see the default values - provisioning Azure Storage and Azure SQL support

```
    var privateLinkZonesToConfigure = [
      {
        groupId: 'blob'
        zoneName: 'privatelink.blob.core.windows.net'
      }
      {
        groupId: 'sqlServer'
        zoneName: 'privatelink.database.windows.net'
      }
    ]
```

If you wish to add more services simply edit the values in `privateLinkZonesToConfigure` in the `deployPrivateLinkZonesandPolicy.bicep` file to meet your needs.

## Deployment ##

### Azure CLI ###
Sample command here:
`az deployment sub create --location northeurope --template-file .\deployPrivateLinkZonesandPolicy.bicep --parameters deployParams.json`

This uses the values defined in `deployParams.json` which at the time of writing defines the name of the resource group to create / use for the private DNS zones.

