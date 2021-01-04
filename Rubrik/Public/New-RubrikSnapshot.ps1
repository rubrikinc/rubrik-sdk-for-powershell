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
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubriksnapshot

    .EXAMPLE
    Get-RubrikVM 'Server1' | New-RubrikSnapshot -Forever

    This will trigger an on-demand backup for any virtual machine named "Server1" that will be retained indefinitely and available under Unmanaged Objects.

    .EXAMPLE
    Get-RubrikFileset 'C_Drive' | New-RubrikSnapshot -SLA 'Gold'

    This will trigger an on-demand backup for any fileset named "C_Drive" using the "Gold" SLA Domain.

    .EXAMPLE
    Get-RubrikDatabase 'DB1' | New-RubrikSnapshot -ForceFull -SLA 'Silver'

    This will trigger an on-demand backup for any database named "DB1" and force the backup to be a full rather than an incremental.

    .EXAMPLE
    Get-RubrikOracleDB -Id OracleDatabase:::e7d64866-b2ee-494d-9a61-46824ae85dc1 | New-RubrikSnapshot -ForceFull -SLA Bronze

    This will trigger an on-demand backup for the Oracle database by its ID, and force the backup to be a full rather than an incremental.

    .EXAMPLE
    New-RubrikSnapShot -Id MssqlDatabase:::ee7aead5-6a51-4f0e-9479-1ed1f9e31614 -SLA Gold

    This will trigger an on-demand backup by ID, in this example it is the ID of a MSSQL Database

    .EXAMPLE
    New-RubrikSnapShot -Id MssqlDatabase:::ee7aead5-6a51-4f0e-9479-1ed1f9e31614 -SLA Gold -SLAPrimaryClusterId 57bbd327-477d-40d8-b1d8-5820b37d88e5

    This will trigger an on-demand backup by ID, in this example it is the ID of a MSSQL Database, creating a snapshot in the Gold SLA on the cluster id specified in SLAPrimaryClusterId
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's id of the object
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(
      ParameterSetName = 'SLA_Name',
      Mandatory = $true
    )]
    [String]$SLA,
    # The PrimaryClusterId of SLA Domain on Rubrik
    [Parameter(ParameterSetName = 'SLA_Name')]
    [String]$SLAPrimaryClusterId = 'local',
    # The snapshot will be retained indefinitely and available under Unmanaged Objects
    [Parameter(
      ParameterSetName = 'SLA_Forever',
      Mandatory = $true
    )]
    [Switch]$Forever,
    # Whether to force a full snapshot or an incremental. Only valid with MSSQL and Oracle Databases.
    [Alias('forceFullSnapshot')]
    [Switch]$ForceFull,
    # SLA id value
    [Parameter(
      ParameterSetName = 'SLA_ByID',
      Mandatory = $true
    )]
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

    # Display a warning if -ForceFull is used with anything other than MSSQL or Oracle
    if ((-Not ($id.contains('OracleDatabase:::') -or $id.contains('MssqlDatabase:::'))) -and $ForceFull) {
      Write-Warning -Message ('Using the ForceFull parameter with a {0} object is not possible, this functionality is only available to Oracle and MSSQL databases. The process will continue to take an incremental snapshot' -f $Id.Split(':')[0])
    }

    # If SLA paramter defined, resolve SLAID
    If ($SLA -or $Forever) {
      $TestSlaSplat = @{
        SLA = $SLA
        DoNotProtect = $Forever
      }
      if ($SLAPrimaryClusterId) {
        $TestSlaSplat.PrimaryClusterID = $SLAPrimaryClusterId
      }
      $SLAID = Test-RubrikSLA @TestSlaSplat
    }
    #endregion One-off

    if ($SLA -and -not $SLAID -and -not $WhatIfPreference) {
      Write-Warning "Could not determine SLAID for '$SLA'"
    } else {
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values) 

      Write-Verbose $uri
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Test-FilterObject -filter ($resources.Filter) -result $result
      
      return $result
    }
  } # End of process
} # End of function