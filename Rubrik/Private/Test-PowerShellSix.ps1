function Test-PowerShellSix {
<#
    .SYNOPSIS
    Test if the PowerShell version is 6 or higher, this is to provide backwards compatibility for older version of PowerShell

    .DESCRIPTION
    Many functions and options within the Rubrik SDK can be enhanced if using PowerShell v6. This function is used to determine the users version of PowerShell
    in order to both provide enhancements and backwards compatability.
#>
    $PSVersionTable.PSVersion.Major -ge 6
}