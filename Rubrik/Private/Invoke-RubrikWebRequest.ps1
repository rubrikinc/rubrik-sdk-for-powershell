function Invoke-RubrikWebRequest {
<#
.SYNOPSIS
Custom wrapper for Invoke-WebRequest, implemented to provide different parameter sets depending on PowerShell version
#>
    param(
        $Uri,
        $Headers,
        $Method,
        $Body 
    )
    
    if (Test-PowerShellSix) {
        Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
    } else {
        Invoke-WebRequest -UseBasicParsing @PSBoundParameters
    }
}