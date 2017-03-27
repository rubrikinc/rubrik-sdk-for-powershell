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
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikFileset -Fileset 'C_Drive' 
      This will return details on the fileset named "C_Drive" assigned to any hosts

      .EXAMPLE
      Get-RubrikFileset -Fileset 'C_Drive' -HostName 'Server1'
      This will return details on the fileset named "C_Drive" assigned to only the "Server1" host

      .EXAMPLE
      Get-RubrikFileset -Fileset 'C_Drive' -SLA Gold
      This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -FilesetID Fileset:::111111-2222-3333-4444-555555555555
      This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikFileset -Relic
      This will return all removed filesets that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the fileset (alias: 'name')
    # Default: Will retrieve information on all known filesets
    # Pipeline: Accepted by property name
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$Fileset,
    # Filter results to include only relic (removed) filesets
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the host using a fileset
    [String]$HostName,
    # Rubrik's fileset id
    [String]$id,     
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('FilesetGet')
  
  }
  
  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($id) 
    {
      $uri += "/$id"
    }
    
    Write-Verbose -Message 'Build the query parameters'
    $query = @()
    $query += Test-QueryObject -object $Relic -location $resources.$api.Query.Relic -query $query
    $query += Test-QueryObject -object $Fileset -location $resources.$api.Query.Search -query $query
    $query += Test-QueryObject -object $HostName -location $resources.$api.Query.SearchHost -query $query
    $query += Test-QueryObject -object (Test-RubrikSLA -SLA $SLA) -location $resources.$api.Query.SLA -query $query
    $uri = New-QueryString -query $query -uri $uri -nolimit $true

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try 
    {
      Write-Verbose -Message "Submitting a request to $uri"
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
      
      Write-Verbose -Message 'Convert JSON content to PSObject (Max 64MB)'
      $result = ExpandPayload -response $r
    }
    catch 
    {
      throw $_
    }

    if (!$id) 
    {      
      Write-Verbose -Message 'Formatting return value'
      $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    }
    
    return $result

  } # End of process
} # End of function
