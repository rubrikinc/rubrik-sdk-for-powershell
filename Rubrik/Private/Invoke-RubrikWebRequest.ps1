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
        $debug = $PSBoundParameters.Values
        $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
    } else {
        $result = Invoke-WebRequest -UseBasicParsing @PSBoundParameters
    }
    
    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"

    return $result
}