#requires -Version 3
function Get-RubrikHyperVVM
{
  <#
      .SYNOPSIS
      Retrieves details on one or more Hyper-V virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikHyperVVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Hyper-V virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervvm

      .EXAMPLE
      Get-RubrikHyperVVM -Name 'Server1'

      This will return details on all Hyper-V virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikHyperVVM -Name 'Server1' -SLA Gold

      This will return details on all Hyper-V virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikHyperVVM -Name 'Server1' -DetailedObject

      This will return all Hyper-V virtual machines named "Server1" and returns the Detailed Objects of these VMs

      .EXAMPLE
      Get-RubrikHyperVVM -Relic

      This will return all removed Hyper-V virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the Hyper-V virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [String]$SLA,
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed Hyper-V VM object, the default behavior of the API is to only retrieve a subset of the full Hyper-V VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    # If we are in RSC mode, call other cmdlet
    if ($global:RubrikConnection.RSCInstance) {
      Write-Verbose -Message "RSC connection detected, redirecting to Get-RubrikRSCHyperVVM"
      $response = Get-RubrikRSCHyperVVM @PSBoundParameters
      return $response
    }

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        if ($result) {
          Get-RubrikHyperVVM -id $result[$i].id
        }
      }
    } else {
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function