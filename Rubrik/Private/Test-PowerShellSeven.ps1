
function Test-PowerShellSeven {
    <#
        .SYNOPSIS
        Test if the PowerShell version is 7 or higher, this is to provide backwards compatibility for older version of PowerShell
    
        .DESCRIPTION
        This function is used to fix the latest Mircrosoft Update which requieres a content-type in the header for Invoke-WebRequest
    #>
        $PSVersionTable.PSVersion.Major -ge 7
    }