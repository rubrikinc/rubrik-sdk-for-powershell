#requires -Version 3
function Get-RubrikFileset
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more filesets known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikFileset cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of filesets
      A number of parameters exist to help narrow down the specific fileset desired
      Note that a fileset name is not required; you can use params (such as HostName and SLA) to do lookup matching filesets

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' 
      This will return details on the fileset named "C_Drive" assigned to any hosts

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
      This will return details on the fileset named "C_Drive" assigned to only the "Server1" host

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' -SLA Gold
      This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
      This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikFileset -Relic
      This will return all removed filesets that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the fileset
    [Alias('Fileset')]
    [String]$Name,
    # Filter results to include only relic (removed) filesets
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the host using a fileset
    [Alias('host_name')]
    [String]$HostName,
    # Filter the summary information based on the ID of a fileset template.
    [Alias('template_id')]
    [String]$TemplateID,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Rubrik's Share id
    [Alias('share_id')]
    [String]$ShareID,
    # Rubrik's fileset id
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
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
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
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