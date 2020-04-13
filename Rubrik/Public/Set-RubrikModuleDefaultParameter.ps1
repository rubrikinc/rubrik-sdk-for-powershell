#requires -Version 3
function Set-RubrikModuleDefaultParameter
{
  <#
      .SYNOPSIS
      Creates or modifies a default value for a given parameter

      .DESCRIPTION
      The Set-RubrikModuleDefaultParameter will allow users to create default values for common parameters within the Rubrik SDK for PowerShell
      These values are stored within the users options file located in $home.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduledefaultparameter

      .EXAMPLE
      Set-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId -ParameterValue local
      Sets the PrimaryClusterId value to always equate to local when not specified.
      If PrimaryClusterId is already defined to have a default value it will be updated, if not, it will be created.

      .EXAMPLE
      Set-RubrikModuleDefaultParameter -Apply
      Applies changes to the user options file to the current PowerShell session
  #>

  [CmdletBinding(DefaultParameterSetName = 'NameValue')]
  [Alias("New-RubrikModuleDefaultParameter")]
  Param(
    # Parameter Name
    [Parameter(ValueFromPipelineByPropertyName = $true,Mandatory=$true,ParameterSetName="NameValue")]
    [string]$ParameterName,
    #Parameter Value
    [Parameter(Mandatory=$true,ParameterSetName="NameValue")]
    [string]$ParameterValue,
    # Apply manual changes to user option file to current PowerShell session
    [Parameter(Mandatory=$true,ParameterSetName="Apply")]
    [switch]$Apply
  )
  Process {

    if ($Apply) {
      $global:rubrikOptions = Sync-RubrikOptionsFile
      Set-RubrikDefaultParameterValues
    }
    else {
      #if property exists update it
      if ($Global:rubrikOptions.DefaultParameterValue.PSObject.Properties[$ParameterName]) {
        $global:rubrikOptions.DefaultParameterValue.$ParameterName = $ParameterValue
      }
      else {
        $global:rubrikOptions.DefaultParameterValue | Add-Member -NotePropertyName $ParameterName -NotePropertyValue $ParameterValue
      }
      # Write options back to file.
      $global:rubrikOptions | ConvertTO-Json | Out-File $Home\rubrik_sdk_for_powershell_options.json
      # Set newly defined values globally.
      Set-RubrikDefaultParameterValues
    }

    return $global:rubrikOptions.DefaultParameterValue

  } # End of process
} # End of function