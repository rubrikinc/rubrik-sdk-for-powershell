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
      Get-RubrikVM -Name 'Server1'
      This will return details on all virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikVM -Name 'Server1' -SLA Gold
      This will return details on all virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVM -Relic
      This will return all removed virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
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
    $resources = (Get-RubrikAPIData -endpoint $function).$api
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
