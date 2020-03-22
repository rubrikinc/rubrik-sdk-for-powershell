#requires -Version 3
function New-RubrikFilesetTemplate
{
  <#
      .SYNOPSIS
      Creates a new fileset template.

      .DESCRIPTION
      Create a new fileset template for Linux hosts, Windows hosts, and NAS shares. This must be
      done before creating a new fileset, as filesets are defined by the templates. Once a Fileset Template
      has been created, the New-RubrikFileset can be used to assign the Fileset Template to a host. Finally,
      the Protect-RubrikFileset is utilized to assign an SLA Domain to the Fileset created. Some caveats that
      are defined by the Rubrik GUI but not applied here:
       - If creating a Windows Fileset Template, you should declare UseWindowsVSS equal to true
       - If you define a pre or post backup script, you need to define error handling
       - If you define a pre or post backup script, you should definte the backup script timeout value to 14400

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikfilesettemplate

      .EXAMPLE
      New-RubrikFilesetTemplate -Name 'FOO' -UseWindowsVSS -OperatingSystemType 'Windows' -Includes 'C:\*.mp3','C:\*.csv'

      Create a Windows Fileset Template to backup .mp3 and .csv on the C:\.

      .EXAMPLE
      New-RubrikFilesetTemplate -Name 'BAR' -ShareType 'SMB' -Includes '*' -Excludes '*.pdf'

      Create a new NAS FilesetTemplate named BAR to backup a NAS SMB share, backing up everything byt excluding all .pdf files.
    #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    #Name of fileset template
    [String]$Name,
    #Boolean - Allow Backup Network Mounts
    [Switch]$AllowBackupNetworkMounts,
    # Boolean - Allow Backup Hidden Folders in Network Mounts
    [Switch]$AllowBackupHiddenFoldersInNetworkMounts,
    # Enable Windows VSS
    [switch]$UseWindowsVSS,
    #Include naming patterns
    [String[]]$Includes,
    #Exclude naming patterns
    [String[]]$Excludes,
    #Exceptions for exclude naming patterns
    [String[]]$Exceptions,
    #Operating System Type
    [Parameter(ParameterSetName='OSType')]
    [ValidateSet('Linux','Windows')]
    [String]$OperatingSystemType,
    #Share Type
    [Parameter(ParameterSetName='ShareType')]
    [ValidateSet('NFS','SMB')]
    [String]$ShareType,
    #Path to pre-backup script
    [String]$PreBackupScript,
    #Path to post-backup script
    [String]$PostBackupScript,
    #Backup script timeout
    [Int]$BackupScriptTimeout,
    #Error handling for backup script
    [ValidateSet('abort','continue')]
    [String]$BackupScriptErrorHandling,
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
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function