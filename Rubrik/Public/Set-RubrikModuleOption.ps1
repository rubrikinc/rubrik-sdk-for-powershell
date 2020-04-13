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
      Set-RubrikModuleOption -Defaults
      This will reset all Rubrik module options to their default values

      .EXAMPLE
      Set-RubrikModuleOption -Apply
      This will apply any changes made to the user option file manually to the current PowerShell session.
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
    [string]$OptionValue,
    # Reset all Module Options to default values
    [Parameter(
      ParameterSetName='Defaults',
      Mandatory=$true)]
    [switch]$Default,
    # Apply manual changes from JSON file to session
    [Parameter(
      ParameterSetName="Apply",
      Mandatory=$true
    )]
    [Switch]$Apply
  )
  Process {

    # if setting all options to default
    if ($Default) {
      # remove all ModuleOptions from global variable and userfile
      $global:rubrikoptions.ModuleOption.psobject.properties | ForEach {$global:rubrikOptions.ModuleOption.psobject.properties.remove($_.Name)}
      $global:rubrikOptions | ConvertTO-Json | Out-File $Home\rubrik_sdk_for_powershell_options.json
      # run sync to recreate them from template
      $global:rubrikOptions = Sync-RubrikOptionsFile

      # Remove Credential from PSDefaultParameterValues if it exists.
      if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
        $Global:PSDefaultParameterValues.Remove("Connect-Rubrik:Credential")
      }
    }
    elseif ($Apply) {
      $global:rubrikOptions = Sync-RubrikOptionsFile
      Set-RubrikDefaultParameterValues
    }
    else {
      # If option exists in global variable...
      if ($Global:rubrikOptions.ModuleOption.PSObject.Properties[$OptionName]) {

        # if using credential path, add the default parameter for connect-rubrik
        if ($OptionName -eq "CredentialPath") {
          if (Test-Path $OptionValue) {
            if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
              $Global:PSDefaultParameterValues."Connect-Rubrik:Credential" = (Import-CliXml -Path $OptionValue)
            }
            else {
              $Global:PSDefaultParameterValues.Add("Connect-Rubrik:Credential",(Import-CliXml -Path $OptionValue))
            }
          }
          elseif ("" -eq $OptionValue) {
            # Remove from DefaultParameterValues
            if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
              $Global:PSDefaultParameterValues.Remove("Connect-Rubrik:Credential")
            }
          }
          else {
            Throw "$OptionValue cannot be found"
          }
        }
        # for all options - update users options file with new value
        $global:rubrikOptions.ModuleOption.$OptionName = $OptionValue
        $global:rubrikOptions | ConvertTO-Json | Out-File $Home\rubrik_sdk_for_powershell_options.json
      }
      # else option doesn't exist in global variable
      else {
        throw "$OptionName doesn't exist in options file."
      }
    }
    return $global:rubrikOptions.ModuleOption
  } # End of process
} # End of function