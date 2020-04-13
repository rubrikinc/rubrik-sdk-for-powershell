#requires -Version 3
function Remove-RubrikModuleDefaultParameter
{
  <#
      .SYNOPSIS
      Removes a defined default value for a parameter

      .DESCRIPTION
      The Remove-RubrikModuleDefaultParameter remove the default value for a specified parameter defined within the users options file.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikmoduledefaultparameter

      .EXAMPLE
      Remove-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId
      This will remove the PrimaryClusterId default value from the user home file. Changes take place immediately.

      .EXAMPLE
      Remove-RubrikModuleDefaultParameter -All
      This will remove all default parameters defined within the users options file.
      Note: This does not affect the default value for Credential defined with the CredentialPath module option
  #>

  [CmdletBinding(DefaultParameterSetName = 'RemoveSingle')]
  Param(
    # Parameter Name
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory=$true,
      Position=0,
      ParameterSetName='RemoveSingle')]
    [string]$ParameterName,
    # Remove all default parameter values
    [Parameter(
      Mandatory = $true,
      ParameterSetName = "RemoveAll")]
    [switch]$All
  )
  Process {

    if ($All) {
      $global:rubrikoptions.DefaultParameterValue.psobject.properties | ForEach {
        $global:rubrikOptions.DefaultParameterValue.psobject.properties.remove($_.Name)
        $global:PSDefaultParameterValues.Remove("*Rubrik*:$($_.Name)")
      }
    }
    else {
      # If property exists, remove from both global options and global psdefaultparametervalues
      if ($Global:rubrikOptions.DefaultParameterValue.PSObject.Properties[$ParameterName]) {
        $global:rubrikOptions.DefaultParameterValue.PSObject.Properties.Remove("$ParameterName")
        $global:PSDefaultParameterValues.Remove("*Rubrik*:$ParameterName")
      }
    }

    # sync options back to file
    $global:rubrikOptions | ConvertTO-Json | Out-File $Home\rubrik_sdk_for_powershell_options.json
    #apply all parameter globally.
    Set-RubrikDefaultParameterValues

    return $global:rubrikOptions.DefaultParameterValue

  } # End of process
} # End of function