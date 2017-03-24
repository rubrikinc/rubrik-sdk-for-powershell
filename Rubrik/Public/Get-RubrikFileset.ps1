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
      Get-RubrikFileset -Name 'C_Drive' 
      This will return details on the fileset named "C_Drive" assigned to any hosts

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
      This will return details on the fileset named "C_Drive" assigned to only the "Server1" host

      .EXAMPLE
      Get-RubrikFileset -Fileset 'C_Drive' -SLA Gold
      This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -FilesetID Fileset:::111111-2222-3333-4444-555555555555
      This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikFileset -Relic False -SLA Bronze
      This will return any fileset that is not a relic (still active) using the SLA Domain matching "Bronze"
  #>

  [CmdletBinding()]
  Param(
    # Name of the fileset
    # If no value is specified, will retrieve information on all filesets
    [Parameter(Position = 0,ValueFromPipeline = $true)]
    [Alias('Name')]
    [String]$Fileset,
    # Filter results based on active, relic (removed), or all filesets
    [Parameter(Position = 1)]
    [ValidateSet('True', 'False')]
    [String]$Relic,
    # SLA Domain policy
    [Parameter(Position = 2,ValueFromPipeline = $true)]
    [Alias('sla_domain_id')]    
    [String]$SLA,
    # Name of the host using a fileset
    [String]$HostName,
    # Fileset id
    [Alias('id')]
    [String]$FilesetID,     
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
    if ($FilesetID) 
    {
      $uri += "/$FilesetID"
    }
    
    Write-Verbose -Message 'Build the query parameters'
    $params = @()
    $params += Test-QueryObject -object $Relic -location $resources.$api.Params.Filter -params $params
    $params += Test-QueryObject -object $Fileset -location $resources.$api.Params.Search -params $params
    $params += Test-QueryObject -object $HostName -location $resources.$api.Params.SearchHost -params $params
    $params += Test-QueryObject -object (Test-RubrikSLA -SLA $SLA) -location $resources.$api.Params.SLA -params $params
    $uri = New-QueryString -params $params -uri $uri -nolimit $true

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

    if (!$FilesetID) 
    {      
      Write-Verbose -Message 'Formatting return value'
      $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    }
    
    return $result

  } # End of process
} # End of function
