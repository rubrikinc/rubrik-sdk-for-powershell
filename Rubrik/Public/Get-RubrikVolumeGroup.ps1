﻿#requires -Version 3
function Get-RubrikVolumeGroup
{
  <#
      .SYNOPSIS
      Retrieves details on one or more volume groups known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVolumeGroup cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of volume groups. By default the 'Includes' property is not populated, unless when querying by ID or by using the -DetailedObject parameter

      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvolumegroup

      .EXAMPLE
      Get-RubrikVolumeGroup -Name 'Quokka volumes'

      This will return details of the volume group named "Quokka Volumes"

      .EXAMPLE
      Get-RubrikVolumeGroup -Hostname 'Server1'

      This will return details on all volume groups from host "Server1".

      .EXAMPLE
      Get-RubrikVolumeGroup -Hostname 'Server1' -SLA Gold

      This will return details on all volume groups of "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVolumeGroup -Relic

      This will return all removed volume groups that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikVolumeGroup -DetailedObject

      This will return full details on all volume groups available on the Rubrik Cluster, this query will take longer as multiple API calls are required. The 'Includes' property will be populated

      .EXAMPLE
      Get-RubrikVolumeGroup -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f

      This will return full details on for the specified VolumeGroup ID
  #>

  [CmdletBinding()]
  Param(
    # Name of the volume group
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('VolumeGroup')]
    [String]$name,
    # Filter results by hostname
    [String]$hostname,
    # Filter results to include only relic (removed) volume groups
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the volume group
    [String]$SLA,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Volume group id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed VolumeGroup object, the default behavior of the API is to only retrieve a subset of the full VolumeGroup object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
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

      # If connected to RSC, redirect to new GQL cmdlet
      if ($global:rubrikConnection.RSCInstance) {
        Write-Verbose -Message "Cluster connected to RSC instance, redirecting to Get-RubrikRSCVolumeGroup"
        $response = Get-RubrikRSCVolumeGroup @PSBoundParameters
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

    # If the Get-RubrikVolumeGroup function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        $updatedresult = Get-RubrikVolumeGroup -id $result[$i].id
        Set-ObjectTypeName -TypeName $resources.ObjectTName -result $updatedresult
      }
    } elseif ($PSBoundParameters.containskey('id') -and (-not $DetailedObject)) {
      $result = $result | Select-Object -Property *,@{
        name = 'includes'
        expression = {
          if ($null -ne $_.volumes) {$_.volumes.mountPoints}
        }
      }
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    } else {
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function