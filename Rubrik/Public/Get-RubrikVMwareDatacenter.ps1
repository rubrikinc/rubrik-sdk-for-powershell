#Requires -Version 3
function Get-RubrikVMwareDatacenter
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of VMware Datacenters registered
            
      .DESCRIPTION
      The Get-RubrikVMwareDatacenter cmdlet will retrieve all of the registered VMware Datacenters within the authenticated Rubrik cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwaredatacenter
            
      .EXAMPLE
      Get-RubrikVMwareDatacenter
      This will return a listing of all of the VMware Datacenter objects known to the connected Rubrik cluster

      Get-RubrikVMwareDatacenter -PrimarClusterId local
      This will return a listing of all of the VMware Datacenter objects whose primary cluster is that of the connected Rubrik cluster.

      .EXAMPLE
      Get-RubrikVMwareDatacenter -Name 'datacenter01'
      This will return a listing of all of the VMware Datacenter objects named 'datacenter01' registered with the connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # Datacenter Object ID
    [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $True,
        ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # Datacenter Object Name
    [Parameter(
        ParameterSetName='Query',
        Position = 0,
        ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,  
    # Return more details on object
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
        for ($i = 0; $i -lt @($result).Count; $i++) {
          $Percentage = [int]($i/@($result).count*100)
          Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
          Get-RubrikVMwareDatacenter -id $result[$i].id
        }
      } else {
        return $result
      }

  } # End of process
} # End of function