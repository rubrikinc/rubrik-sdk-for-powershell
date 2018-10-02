function Test-PowerShellSix {
<#
.SYNOPSIS
Test if the PowerShell version is 6 or higher, this is to provide backwards compatibility for older version of PowerShell
#>
    $PSVersionTable.PSVersion.Major -ge 6
}