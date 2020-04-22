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
      Set-RubrikModuleDefaultParameter -Sync
      Syncs changes to the user options file to the current PowerShell session
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
    # Sync any manual changes within user option file to current PowerShell session
    [Parameter(Mandatory=$true,ParameterSetName="Sync")]
    [switch]$Sync
  )
  Process {

    if ($Sync) {
      Update-RubrikModuleOption -Action "Sync"
    }
    else {
      $ModuleOptionSplat = @{
        Action = "AddUpdate"
        OptionType = "DefaultParameterValue"
        OptionName = $ParameterName
        OptionValue = $ParameterValue
      }
      Update-RubrikModuleOption @ModuleOptionSplat
    }

    return $global:rubrikOptions.DefaultParameterValue

  } # End of process
} # End of function