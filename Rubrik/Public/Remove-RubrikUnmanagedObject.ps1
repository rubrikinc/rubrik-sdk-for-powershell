#Requires -Version 3
function Remove-RubrikUnmanagedObject
{
  <#
      .SYNOPSIS
      Removes one or more unmanaged objects known to a Rubrik cluster

      .DESCRIPTION
      The Remove-RubrikUnmanagedObject cmdlet is used to remove unmanaged objects that have been stored in the cluster
      In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikunmanagedobject

      .EXAMPLE
      Get-RubrikUnmanagedObject | Remove-RubrikUnmanagedObject
      This will remove all unmanaged objects from the cluster

      .EXAMPLE
      Get-RubrikUnmanagedObject -Type 'WindowsFileset' | Remove-RubrikUnmanagedObject -Confirm:$false
      This will remove any unmanaged objects related to filesets applied to Windows Servers and supress confirmation for each activity

      .EXAMPLE
      Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1' | Remove-RubrikUnmanagedObject
      This will remove any unmanaged objects associated with any workload named "Server1" that is currently unprotected
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The id of the unmanaged object.
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('objectId')]
    [String]$id,
    # The type of the unmanaged object. This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('objectType')]
    [String]$Type,
    # Forces object to be removed regardless of SLA Domain assignment. From Rubrik CDM 5.0 and above, an unmanaged object cannot be deleted if snapshots exist with an SLA Domain assigned to them. The -Force parameter will override this allowing the object, and the snapshots, to be deleted.
    [Switch]$Force,
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

    # if force is specified and CDM is > 5.0 remove SLA domain from snapshots first
    if ($Force -and 5 -ge [float]$rubrikconnection.version.substring(0,3)) {
      Write-Verbose -Message "Force parameter specified. Removing SLA Domain from existing snapshots"
      $snapshots = Invoke-RubrikRestCall -api 'internal' -Endpoint "unmanaged_object/$id/snapshot" -Method "GET"
      Write-Verbose -Message "Assigning UNPROTECTED SLA Domain to snapshot ids: $($snapshots.data.id)"
      $snapshotarray = New-Object -TypeName System.Collections.Generic.List[String]
      $snapshots.data.id | ForEach { $snapshotarray.Add($_)}
      $body = New-Object -TypeName PSObject -Property @{"slaDomainId"="UNPROTECTED";"snapshotIds"=$snapshotarray}
      Invoke-RubrikRestCall -Endpoint 'unmanaged_object/snapshot/assign_sla' -Method "POST" -api "internal" -Body $body
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result



  } # End of process
} # End of function