#requires -Version 3
function Get-RubrikModuleDefaultParameter
{
  <#
      .SYNOPSIS
      Retrieves a customized Rubrik module option

      .DESCRIPTION
      The Get-RubrikModuleOption will retrieve one or more options within the users home directory

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduleoption

      .EXAMPLE
      Get-RubrikModuleOption

      Retrieves all the customized module options
  #>

   [CmdletBinding()]
  Param(
    # Parameter Name
    [Parameter(Position=0)]
    [string]$ParameterName
  )
  Process {

    if ($ParameterName) {
      return  $global:rubrikOptions.DefaultParameterValue | Select $ParameterName
    }
    else {
      return $Global:rubrikOptions.DefaultParameterValue
    }


  } # End of process
} # End of function