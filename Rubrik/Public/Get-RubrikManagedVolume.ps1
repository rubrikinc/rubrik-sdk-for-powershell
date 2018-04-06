#requires -Version 3
function Get-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Gets data on a Rubrik managed volume 

      .DESCRIPTION
      The Get-RubrikManagedVolume cmdlet is used to retrive information 
      on one or more managed volumes that are being protected 
      with Rubrik.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikManagedVolume -name sqltest

      Get a managed volume named sqltest

      .EXAMPLE
      Get-RubrikManagedVolume -SLA 'Foo'

      Get all managed volumes protected by the 'Foo' SLA domain.
  #>

  [CmdletBinding()]
  Param(
    # id of managed volume
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Name of managed volume
    [String]$Name,
    # SLA name that the managed volume is protected under
    [String]$SLA,
    # SLA id that the managed volume is protected under
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # Filter results to include only relic (removed) databases
    [Alias('is_relic')]
    [Switch]$Relic,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
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

    #region One-off
    if($SLA){
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function