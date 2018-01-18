#Requires -Version 3
function New-RubrikSnapshot
{
  <#  
      .SYNOPSIS
      Takes an on-demand Rubrik snapshot of a protected object

      .DESCRIPTION
      The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific object (virtual machine, database, fileset, etc.)

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikVM 'Server1' | New-RubrikSnapshot -Inherit
      This will trigger an on-demand backup for any virtual machine named "Server1" using the existing SLA domain

      .EXAMPLE
      Get-RubrikFileset 'C_Drive' | New-RubrikSnapshot -SLA 'Gold'
      This will trigger an on-demand backup for any fileset named "C_Drive" using the "Gold" SLA Domain

      .EXAMPLE
      Get-RubrikDatabase 'DB1' | New-RubrikSnapshot -ForceFull -Inherit
      This will trigger an on-demand backup for any database named "DB1" and force the backup to be a full rather than an incremental.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's id of the object
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,    
    # Whether to force a full snapshot or an incremental. Only valid with MSSQL Databases.
    [Alias('forceFullSnapshot')]
    [Switch]$ForceFull,
    # SLA id value
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
    #endregion One-off

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    
    return $result

  } # End of process
} # End of function