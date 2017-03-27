#requires -Version 3
function Get-RubrikVM
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikVM -VM 'Server1'
      This will return details on all virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikVM -VM 'Server1' -SLA Gold
      This will return details on all virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVM -Relic
      This will return all removed virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the virtual machine (alias: 'name')
    # Default: Will retrieve information on all known virtual machines
    # Pipeline: Accepted by property name
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$VM,
    # Filter results to include only relic (removed) virtual machines
    [Switch]$Relic,
    # SLA Domain policy assigned to the virtual machine
    [String]$SLA, 
    # Virtual machine id
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
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMGet')
  
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
    $query += Test-QueryObject -object $Relic -location $resources.$api.Query.Relic -params $query
    $query += Test-QueryObject -object $VM -location $resources.$api.Query.Search -params $query
    $query += Test-QueryObject -object (Test-RubrikSLA -SLA $SLA) -location $resources.$api.Query.SLA -params $query
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
