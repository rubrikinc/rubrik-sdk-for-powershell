#requires -Version 3
function Set-RubrikModuleOption
{
  <#
      .SYNOPSIS
      Sets an option value within the users option file

      .DESCRIPTION
      The Set-RubrikModuleOption will set an option value within the users option value and immediately apply the change.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduleoption

      .EXAMPLE
      Set-RubrikModuleOption -OptionName ApplyCustomViewDefinitions -OptionValue "False"
      This will disable the application of custom view definitions to returned objects, instead displaying a complete list of properties.

      .EXAMPLE
      Get-Credential | Export-CliXml -Path c:\creds\creds.xml
      Set-RubrikModuleOption -OptionName CredentialPath -OptionValue "c:\creds\creds.xml"
      This will create a default credential file to be used with Connect-Rubrik only. Encrypted credentials will be stored on the local filesystem and automatically sent to Connect-Rubrik by applying them to the global $PSDefaultParameterValues variable

      .EXAMPLE
      Set-RubrikModuleOption -OptionName CredentialPath -OptionValue ""
      This will remove the application of sending default credentials to Connect-Rubrik. Note: It will not remove any generated credential files.

      .EXAMPLE
      Set-RubrikModuleOption -Default
      This will reset all Rubrik module options to their default values

      .EXAMPLE
      Set-RubrikModuleOption -Sync
      This will sync any changes made to the user option file manually to the current PowerShell session.
  #>

  [CmdletBinding(DefaultParameterSetName = 'NameValue')]
  Param(
    # Option name to change
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      ParameterSetName='NameValue',
      Position=0,
      Mandatory=$true)]
    [string]$OptionName,
    # Desired value for option
    [Parameter(
      ParameterSetName='NameValue',
      Position=1,
      Mandatory=$true)]
    [AllowEmptyString()]
    [string]$OptionValue,
    # Reset all Module Options to default values
    [Parameter(
      ParameterSetName='Defaults',
      Mandatory=$true)]
    [switch]$Default,
    # Apply manual changes from JSON file to session
    [Parameter(
      ParameterSetName="Sync",
      Mandatory=$true
    )]
    [Switch]$Sync
  )
  Process {

    # if setting all options to default
    if ($Default) {
      Update-RubrikModuleOption -Action "Default" -OptionType "ModuleOption"
    }
    elseif ($Sync) {
      Update-RubrikModuleOption -Action "Sync"
    }
    else {
      # This means we are adding or updating (no remove on ModuleOptions)
      # First, make sure the option exists
      if ($Global:rubrikOptions.ModuleOption.PSObject.Properties[$OptionName]) {
        $ModuleOptionSplat = @{
          Action = "AddUpdate"
          OptionType = "ModuleOption"
          OptionName = $ParameterName
          OptionValue = $ParameterValue
        }
        Update-RubrikModuleOption @ModuleOptionSplat
      }
      else {
        # Option doesn't exist
        throw "$OptionName doesn't exist in options file."
      }
    }
    return $global:rubrikOptions.ModuleOption
  } # End of process
} # End of function