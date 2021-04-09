#Requires -Version 3
function Invoke-RubrikVgfUpgrade
{
  <#
      .SYNOPSIS
      Connects to Rubrik and sets the forceFull flag of any number of Volume Groups that needs upgrade

      .DESCRIPTION
      The Invoke-RubrikVgfUpgrade cmdlet will update the forceFull flag of a given list of Volume Groups.
      If these Volume Groups are using the SMB backup method, their forceFull flag will be set, and they will be upgraded to use the fast VHDX method in the next backup.

      .NOTES
      Written by Feng Lu for community usage
      github: fenglu42

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikvgfupgrade

      .EXAMPLE
      Invoke-RubrikVgfUpgrade -VGList VolumeGroup:::e0a04776-ab8e-45d4-8501-8da658221d74, VolumeGroup:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322

      This will set the forceFull flag of the given volume groups, if they need upgrade

      .EXAMPLE
      Get-RubrikVolumeGroup -hostname ad.flammi.home | Invoke-RubrikVgfUpgrade
      
      This will set the forceFull flag of the Volume Group belonging to the specified hostname, if it needs upgrade
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # VolumeGroup ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$VGList,
    # Print details during confirmation
    [switch]$notPrintingDetail,
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

    #get all volume groups format report
    $vgfReport = Get-RubrikVgfReport

    #filter Volume Groups by input and need for upgrade
    $vgIdsToUpgrade = @()
    $vgIdToNameMap = @{}
    foreach ($vgf in $vgfReport) {
      if ($VGList.Contains($vgf.ID)) {
        if($vgf.usedFastVhdx) {
          Write-Host "Skipping upgrade on $($vgf.ID) since its latest snapshot is already in the new fast VHDX format."
        }
        else {
          $vgIdsToUpgrade += $vgf.ID
          $vgIdToNameMap.Add($vgf.ID, $vgf.Name)
        }
      }
    }

    if ($vgIdsToUpgrade.count -eq 0) {
        Write-Host "No Volume Group to upgrade."
        return $null
    }

    #confirm action
    $promptString = "This command will set the following Volume Groups for format upgrade:

$($vgIdToNameMap.Values -join "`r`n")
"
    if ($notPrintingDetail) {
      $promptString = ""
    }

    $confirmation = Read-Host "$promptString
Do you want to proceed? (y/N) "

    if ($confirmation -ne 'y') {
      return $null
    }

    #invoke upgrade by setting forceFull for each Volume Group
    foreach ($id in $vgIdsToUpgrade) {
      Write-Host "Setting $($vgIdToNameMap[$id]) for format upgrade on next backup..."
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters @($id) -uri $uri

      #add forceFull to body
      $body = @{
        $resources.Body.forceFull = $true
      }

      $body = ConvertTo-Json $body
      Write-Verbose "Body is $body"
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      Write-Verbose "Done for $id with result $result"
    }
    Write-Host ""
    Write-Host "Successfully set the following Volume Groups for upgrade on the next backup:"
    Write-Host ($vgfReport | Where-Object {$vgIdsToUpgrade.contains($_.ID)} | Select-Object -ExpandProperty Name)
  } # End of process
} # End of function
