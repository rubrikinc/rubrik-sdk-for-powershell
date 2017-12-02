#Requires -Version 3
function New-RubrikManagedVolumeExport
{
  <#  
      .SYNOPSIS
      Create a new Export from a Managed Volume
      
      .DESCRIPTION
      The New-RubrikManagedVolumeExport cmdlet is used to create a Live Mount (clone) of a Managed Volume.
      
      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikManagedVolumeExport -id '11111111-2222-3333-4444-555555555555'
      This will create a new export based on snapshot id "11111111-2222-3333-4444-555555555555"

      
      .EXAMPLE
      New-RubrikManagedVolumeExport -id '11111111-2222-3333-4444-555555555555' -hostPatterns '1.2.3.4'
      This will create a new export based on snapshot id "11111111-2222-3333-4444-555555555555" allow host 1.2.3.4 to mount it

      .EXAMPLE
      Get-RubrikManagedVolume 'oracle' | Get-RubrikSnapshot -Date '03/01/2017 01:00' | New-RubrikManagedVolumeExport -hostPatterns '1.2.3.4'
      This will create a new eport based on the closet snapshot found on March 1st, 2017 @ 01:00 AM and allow host 1.2.3.4 to access it

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the snapshot
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    # ID of host for the mount to use 
    [String]$id,
    # List of hosts allowed to mount
    [String]$HostPatterns,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function