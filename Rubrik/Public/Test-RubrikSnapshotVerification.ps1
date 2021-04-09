function Test-RubrikSnapshotVerification
{
  <#
    .SYNOPSIS
    Tests a snapshot or multiple snapshots for consistency

    .DESCRIPTION
    The Test-RubrikSnapshotVerification cmdlet can be used to validate the fingerprint of a snapshot(s) for consistency and reliablity.

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: JaapBrasser

    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/test-rubriksnapshotverification

    .EXAMPLE
    Test-RubrikSnapshotVerification -id 'VirtualMachine:::111'

    This will initiate the test for all snapshots on VM with id 111. A callback uri is returned and an ID in order to track the request

    .EXAMPLE
    Get-RubrikVM jaapsvm | Test-RubrikSnapshotVerification

    This will initiate the test for all snapshots on VM 'jaapsvm', A callback uri is returned and an ID in order to track the request

    .EXAMPLE
    Start-RubrikDownload -uri (Test-RubrikSnapshotVerification -id 'VirtualMachine:::111' | Get-RubrikRequest -WaitForCompletion).links[1].href

    This will initiate the test for all snapshots on VM with id 111. The cmdlet will then wait for the Snapshot verification to be completed, when this happens the file is stored to the current folder

    .EXAMPLE
    Invoke-RestMethod -uri (Test-RubrikSnapshotVerification -id 'VirtualMachine:::111' | Get-RubrikRequest -WaitForCompletion).links[1].href | ConvertFrom-Csv

    This will initiate the test for all snapshots on VM with id 111. The cmdlet will then wait for the Snapshot verification to be completed, when this happens the results are converted from csv and displayed in the console
  #>

  [CmdletBinding(
    SupportsShouldProcess = $true
  )]
  Param(
    # Object id value
    [Parameter(
      Position = 0,
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [Alias('objectId')]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Snapshot id value(s)
    [Alias('snapshotIdsOpt')]
    [ValidateNotNullOrEmpty()]
    [String[]]$SnapshotID,
    # Location id value(s)
    [Alias('locationIdOpt')]
    [ValidateNotNullOrEmpty()]
    [String]$LocationID,
    # The datetime stamp to verify snapshots after
    [Alias('shouldVerifyAfterOpt')]
    [ValidateNotNullOrEmpty()]
    [datetime]$VerifyAfter,
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
    if ($VerifyAfter) {
      $VerifyAfter = ConvertTo-UniversalZuluDateTime -DateTimeValue $VerifyAfter
    }

    if ($PSCmdlet.ShouldProcess("snapshot id: '$id'", "Validating backup of '$id'")) {
      $uri = New-URIString -server $Server -endpoint ($resources.URI)
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function