#Requires -Version 3
function Protect-RubrikVolumeGroup
{
  <#
    .SYNOPSIS
    Connects to Rubrik and assigns an SLA to a VolumeGroup

    .DESCRIPTION
    The Protect-RubrikVolumeGroup cmdlet will assign a SLA Domain to Volumes on a window host.
    The SLA Domain contains all policy-driven values needed to protect workloads.
    You can first use Get-RubrikVolumeGroup to get the one volume group you want to protect, and then pipe the results to Protect-RubrikVolumeGroup.
    You can exclude volumes by specifiying the driveletter or the volumeID.

    .NOTES
    Written by Pierre Flammer for community usage
    Twitter: @PierreFlammer
    GitHub: Pierre-PvF

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikvolumegroup

    .EXAMPLE
    Protect-RubrikVolumeGroup -id VolumeGroup:::2038fecb-745b-4d2d-8a71-cf2fc0d0be80 -SLA 'Gold'
    This will assign the Gold SLA Domain to the specified Volume Group, including all volumes presently on the system

    .EXAMPLE
    Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold'
    This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system

    .EXAMPLE
    Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold' -ExcludeDrive C,E
    This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system except for  the C and E drives

    .EXAMPLE
    Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold' -ExcludeIDs 824fd711-ad69-4b56-bb83-613b0125f178
    This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system excpt for the disks with the specified IDs
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # VolumeGroup ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID = (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$true),
    # Specifiy MountPoints to be excluded
    [Array]$ExcludeDrive,
    # Specifiy IDs to be excluded (alternative to MountPoints)
    [Array]$ExcludeIDs,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #### Generating $body ####

    #add SLA to body
    $body = @{
        $resources.Body.configuredSlaDomainId = $SLAID
        volumeIdsIncludedInSnapshots = @()
    }

    #get hostid of volumegroup
    $volumegroup = Get-RubrikVolumeGroup -id $id
    #get all volumes of the host, so we can exclude drives or IDs
    $volumes = Get-RubrikHostVolume -id $volumegroup.hostid

    #remove all excluded mount points
    foreach ($volume in $volumes) {
        foreach ($mp in $ExcludeDrive) {
            if ($mp -like $volume.mountPoints.Replace(":\","")) {
                $volumes = $volumes | Where-Object { $_.id –ne $volume.id }
                #$body.volumeIdsIncludedInSnapshots = $body.volumeIdsIncludedInSnapshots -  $volume.id
                Write-Verbose -Message "Not protecting Volume with MountPoint: $volume.mountPoints" -Verbose
            }
        }
    }

    #remove all excluded IDs
    foreach ($volume in $volumes) {
        foreach ($eID in $ExcludeID) {
            if ($eID -eq $volume.id ) {
                $volumes = $volumes | Where-Object { $_.id –ne $volume.id }
                #$body.volumeIdsIncludedInSnapshots -=  $volume.id
                Write-Verbose -Message "Not protecting Volume with ID $volume.id" -Verbose
            }
        }
    }

    foreach ($volume in $volumes) {
        $body.volumeIdsIncludedInSnapshots +=  $volume.id
    }


    $body = ConvertTo-Json $body
    #### Generating $body ####
    Write-Verbose "Body is $body"
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    return $result

  } # End of process
} # End of function