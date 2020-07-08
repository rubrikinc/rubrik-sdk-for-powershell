function Invoke-RubrikWebRequest {
    <#
        .SYNOPSIS
        Custom wrapper for Invoke-WebRequest

        .DESCRIPTION
        This function was built in order to provide different parameter sets to the Invoke-WebRequest cmdlet depending on the end-users PowerShell verison.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        $Uri,
        $Headers,
        $Method,
        $Body
    )
    
    if (Test-PowerShellSix) {
        if ($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) {
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
        }
    } else {
        if ($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) {
            $result = Invoke-WebRequest -UseBasicParsing -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            $result = Invoke-WebRequest -UseBasicParsing @PSBoundParameters
        }
    }
    
    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"

    return $result
}