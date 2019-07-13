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
        $result = Invoke-WebRequest -ErrorAction Stop -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
    } else {
        $result = Invoke-WebRequest -ErrorAction Stop -UseBasicParsing @PSBoundParameters
    }
    
    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"

    return $result
}