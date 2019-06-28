#Requires -Version 3

function Protect-RubrikTag
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value

      .DESCRIPTION
      The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Make sure you have PowerCLI installed and connect to the required vCenter Server.

      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikTag.html

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Gold'
      This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium'
      This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -DoNotProtect
      This will remove protection from any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -Inherit
      This will flag any VM tagged with Gold in the Rubrik category to inherit the SLA Domain of its parent object
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # vSphere Tag
    [Parameter(Mandatory = $true)]
    [String]$Tag,
    # vSphere Tag Category
    [Parameter(Mandatory = $true)]
    [String]$Category,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
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

    # Check to ensure that a session to the vSphere Center Server exists and load the needed header data for authentication
    Test-VMwareConnection

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

    Write-Verbose -Message "Gathering a list of VMs associated with Category $Category and Tag $Tag"
    try
    {
      $vmlist = Get-VM -Tag (Get-Tag -Name $Tag -Category $Category) | Get-View
      # This will pull out the vCenter UUID assigned to the parent vCenter Server by Rubrik
      # Reset switches to prevent Get-RubrikVM from picking them up (must be a better way?)
      $DoNotProtect = $false
      $Inherit = $false
      if ($vmlist.count -gt 0) {
        $vcuuid = ((Get-RubrikVM -VM ($vmlist[0].Name) -PrimaryClusterID 'local' | where-object {$_.isRelic -eq $false}).vCenterId) -replace 'vCenter:::', ''
      }
    }
    catch
    {
      throw $_
    }

    if ($vmlist.count -eq 0) {
      Write-Verbose -Message "No VMs found with Category $Category and Tag $Tag"
      return $null
    }

    Write-Verbose -Message 'Building an array of Rubrik Managed IDs'
    [array]$vmbulk = @()
    foreach ($_ in $vmlist)
    {
      $vmbulk += 'VirtualMachine:::' + $vcuuid + '-' + $($_.moref.value)
      Write-Verbose -Message "Found $($vmbulk.count) records"
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $SLAID
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message 'Creating the array to mass assign the list of IDs'
    $body = @{
      managedIds = $vmbulk
    }
    $body = ConvertTo-Json -InputObject $body
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
