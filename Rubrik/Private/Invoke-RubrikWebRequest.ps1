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
        if ($null -ne $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -or $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -gt 99) {
            Write-Verbose -Message "Invoking request with a custom timeout of $($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) seconds"
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            Write-Verbose -Message "No custom timeout specified or custom timeout is less than 100 seconds, invoking request with default value of 100 seconds"
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
        }
    } else {
        if ($null -ne $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -or $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -gt 99) {
            Write-Verbose -Message "Invoking request with a custom timeout of $($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) seconds"
            $result = Invoke-WebRequest -UseBasicParsing -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            Write-Verbose -Message "No custom timeout specified or custom timeout is less than 100 seconds, invoking request with default value of 100 seconds"
            $result = Invoke-WebRequest -UseBasicParsing @PSBoundParameters
        }
    }

    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"

    return $result
}