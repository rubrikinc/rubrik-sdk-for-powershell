#requires -Version 3
function Get-RubrikModuleDefaultParameter
{
  <#
      .SYNOPSIS
      Retrieves the default parameter values

      .DESCRIPTION
      The Get-RubrikModuleDefaultParameter will retrieve the default parameter values configured within the users options file.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduledefaultparameter

      .EXAMPLE
      Get-RubrikModuleDefaultParameter
      Retrieves all the default parameter values

      .EXAMPLE
      Get-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId
      Retrieves the PrimaryClusterId default parameter value
  #>

   [CmdletBinding()]
  Param(
    # Parameter Name
    [Parameter(Position=0)]
    [string]$ParameterName
  )
  Process {

    if ($ParameterName) {
      return  $global:rubrikOptions.DefaultParameterValue | Select-Object -Property $ParameterName
    }
    else {
      return $Global:rubrikOptions.DefaultParameterValue
    }

  } # End of process
} # End of function