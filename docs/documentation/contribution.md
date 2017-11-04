Contribution
============================

Everyone is welcome to contribute to this project. Here are the high level steps involved:

1. Create a fork of the project into your own repository.
1. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
1. Make all your necessary changes in your feature branch.
1. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.

Creating a New Function
------------------------

To keep the module simple, each function is saved as its own ps1 file and stored in ``Rubrik\Public``. The naming format is ``Verb-RubrikNoun.ps1`` in which ``Verb`` is a Microsoft approved verb (Use ``Get-Verb`` to see the list) and the noun is singular. Therefore "Get-RubrikVM" is acceptable but "Get-RubrikVMs" is not. You can quickly bootstrap this process by using either the ``template\Verb-RubrikNoun.ps1`` file as a template or pick from an existing function that contains code you'd like to re-use.

Every function needs to have two specific variables included and should not be removed:

1. ``[String]$Server = $global:RubrikConnection.server`` - Stores the Rubrik cluster's IP or FQDN
1. ``[String]$api = $global:RubrikConnection.api`` - Stores the API version

Storing API Data
------------------------

All API specific data for a function is abstracted into a helper function located in ``Rubrik\Private`` named ``Get-RubrikAPIData.ps1``. This separates function logic from function data and allows for simple iterations to cross different API versions while also making unit testing much simpler. If your function is going to call the API directly, all API specific requirements should be stored in ``Get-RubrikAPIData.ps1``. Data is stored in a hashtable like the sample below:

    Example                   = @{
      v1 = @{
        Description = 'Details about the API endpoint'
        URI         = 'The URI expressed as /api/v#/endpoint'
        Method      = 'Method to use against the endpoint'
        Body        = 'Parameters to use in the body'
        Query       = 'Parameters to use in the URI query'
        Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
        Filter      = 'If the result content needs to be filtered based on key names, express them here'
        Success     = 'The expected HTTP status code for a successful call'
      }
    }

Once data for the endpoint is stored, the function template should work in most cases. Most of the heavy lifting is handled by private functions that are called in order to build the query (path) parameters, construct a body payload, and filter the results.

Building a Query
------------------------

For many endpoints, a query is constructed using the endpoint's path. This is fairly common when using the ``id`` value.

Below, let's look at ``Get-RubrikDatabase`` and how it builds a query. There are 4 different parameters available for the query: ``instance_id``, ``effective_sla_domain_id``, ``primary_cluster_id``, and ``is_relic``. By placing these objects in the Query section, we've informed the function that they are available.

Note that the key and value match because this is the first version of the API; should the parameter name change in the future, the value would change to match it, but the key would remain static to avoid re-writing anything in the function itself.

    'Get-RubrikDatabase'      = @{
      v1 = @{
        Description = 'Returns a list of summary information for Microsoft SQL databases.'
        URI         = '/api/v1/mssql/db'
        Method      = 'Get'
        Body        = ''
        Query       = @{
          instance_id             = 'instance_id'
          effective_sla_domain_id = 'effective_sla_domain_id'
          primary_cluster_id      = 'primary_cluster_id'
          is_relic                = 'is_relic'
        }
        Result      = 'data'
        Filter      = @{
          'Name'   = 'name'
          'SLA'    = 'effectiveSlaDomainName'
          'Hostname' = 'rootProperties.rootName'
          'Instance' = 'instanceName'
        }
        Success     = '200'
      }
    }

The parameter names aren't very user friendly. In order to use friendly parameter names within the function, a relationship is created using an alias. Below are the parameters available in the ``Get-RubrikDatabase`` function. Notice how the ``[Switch]$Relic`` switch has an alias of ``[Alias('is_relic')]`` to match the API's parameter? This creates a relationship so that the function knows to build a query using the value of this parameter.

In this case, if the user sets the switch to $true, the ``is_relic`` query will be added to the path. The same goes for ``$PrimaryClusterID`` and ``$SLAID``.

    Param(
        # Name of the database
        [Alias('Database')]
        [String]$Name,
        # Filter results to include only relic (removed) databases
        [Alias('is_relic')]
        [Switch]$Relic,
        # SLA Domain policy assigned to the database
        [String]$SLA,
        # Name of the database instance
        [String]$Instance,
        # Name of the database host
        [String]$Hostname,
        # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        [Alias('primary_cluster_id')]
        [String]$PrimaryClusterID,
        # Rubrik's database id value
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$id,
        # SLA id value
        [Alias('effective_sla_domain_id')]
        [String]$SLAID,
        # Rubrik server IP or FQDN
        [String]$Server = $global:RubrikConnection.server,
        # API version
        [ValidateNotNullorEmpty()]
        [String]$api = $global:RubrikConnection.api
    )

If the Query building function doesn't find a particular parameter in the API data, it ignores the value with respect to building a query.

Building a Body
------------------------

Constructing a body payload is very similar to a query. Let's look at the ``New-RubrikMount`` function as an example. Notice how it has a body section with parameters defined? The body parameters follow the same rules as query parameters do: include the key/value pairs in the API data, and then use aliases within the function to build a relationship.

    'New-RubrikMount'         = @{
      v1 = @{
        Description = 'Create a live mount request with given configuration'
        URI         = '/api/v1/vmware/vm/snapshot/{id}/mount'
        Method      = 'Post'
        Body        = @{
          hostId               = 'hostId'
          vmName               = 'vmName'
          dataStoreName        = 'dataStoreName'
          disableNetwork       = 'disableNetwork'
          removeNetworkDevices = 'removeNetworkDevices'
          powerOn              = 'powerOn'
        }
        Query       = ''
        Result      = ''
        Filter      = ''
        Success     = '202'
      }
    }

And here's the PowerShell code to see the body parameter aliases. See how ``[String]$MountName`` has an alias of ``[Alias('vmName')]`` to avoid user confusion? And because that value is declared in the body section of the API data, the private functions know to use that parameter to construct the body payload.

    Param(
        # Rubrik id of the snapshot
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [String]$id,
        # ID of host for the mount to use
        [String]$HostID,
        # Name of the mounted VM
        [Alias('vmName')]
        [String]$MountName,
        # Name of the data store to use/create on the host
        [String]$DatastoreName,
        # Whether the network should be disabled on mount.This should be set true to avoid ip conflict in case of static IPs.
        [Switch]$DisableNetwork,
        # Whether the network devices should be removed on mount.
        [Switch]$RemoveNetworkDevices,
        # Whether the VM should be powered on after mount.
        [Alias('powerOn')]
        [Switch]$PowerState,
        # Rubrik server IP or FQDN
        [String]$Server = $global:RubrikConnection.server,
        # API version
        [String]$api = $global:RubrikConnection.api
    )

Building a Filter
------------------------

Not every API endpoint has the ability to filter results as desired. In those cases, the filter section of the API data is used to provide additional result filtering for the user.

Let's take a peek at ``Get-RubrikVM`` as an example. Notice how the filter section is different from the query and body sections. The filter keys correspond to the function's actual parameter names. The values correspond to the keys found in the result data. This relationship is used to filter specific key/value pairs in the result for user driven filter criteria.

    'Get-RubrikVM'            = @{
      v1 = @{
        Description = 'Get summary of all the VMs'
        URI         = '/api/v1/vmware/vm'
        Method      = 'Get'
        Body        = ''
        Query       = @{
          is_relic                = 'is_relic'
          name                    = 'name'
          effective_sla_domain_id = 'effective_sla_domain_id'
        }
        Result      = 'data'
        Filter      = @{
          'Name' = 'name'
          'SLA' = 'effectiveSlaDomainName'
        }
        Success     = '200'
      }
    }

Let's take the ``'SLA' = 'effectiveSlaDomainName'`` as an example: a user enters a friendly SLA Domain name into the ``$SLA`` parameter. When the results come back from the endpoint, this friendly name is compared against the results. PowerShell looks at the ``effectiveSlaDomainName`` key and filters out anything that doesn't match. If the user entered the word "Gold", the function would filter out any results that aren't part of the "Gold" SLA Domain.

There is no need to create an alias because the actual parameter name is used (without the ``$`` symbol).

    Param(
        # Name of the virtual machine
        [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
        [Alias('VM')]
        [String]$Name,
        # Filter results to include only relic (removed) virtual machines
        [Alias('is_relic')]
        [Switch]$Relic,
        # SLA Domain policy assigned to the virtual machine
        [String]$SLA,
        # Virtual machine id
        [String]$id,
        # SLA id value
        [Alias('effective_sla_domain_id')]
        [String]$SLAID,
        # Rubrik server IP or FQDN
        [String]$Server = $global:RubrikConnection.server,
        # API version
        [String]$api = $global:RubrikConnection.api
    )

Updating the Module Manifest
------------------------

The final step is to update the module manifest and add the new function to the ``FunctionsToExport`` value. This is done in the ``Rubrik\Rubrik.psd1`` file.