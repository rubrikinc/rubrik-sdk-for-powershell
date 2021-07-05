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

    # Write Debug information
    Write-Debug -Message ($PSBoundParameters.GetEnumerator()|Out-String)

    if (Test-UnicodeInString -String $Body) {
        $PSBoundParameters.Add('ContentType', 'text/plain; charset=utf-8')
        Write-Verbose -Message ('Submitting "{0}" request as "text/plain; charset=utf-8"' -f $Method)
    }

    if (Test-PowerShellSix) {
        if (-not [string]::IsNullOrWhiteSpace($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) -or $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -gt 99) {
            Write-Verbose -Message "Invoking request with a custom timeout of $($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) seconds"
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            Write-Verbose -Message "No custom timeout specified or custom timeout is less than 100 seconds, invoking request with default value of 100 seconds"
            $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
        }
    } else {
        if (-not [string]::IsNullOrWhiteSpace($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) -or $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut -gt 99) {
            Write-Verbose -Message "Invoking request with a custom timeout of $($rubrikOptions.ModuleOption.DefaultWebRequestTimeOut) seconds"
            $result = Invoke-WebRequest -UseBasicParsing -TimeoutSec $rubrikOptions.ModuleOption.DefaultWebRequestTimeOut @PSBoundParameters
        } else {
            Write-Verbose -Message "No custom timeout specified or custom timeout is less than 100 seconds, invoking request with default value of 100 seconds"
            $result = Invoke-WebRequest -UseBasicParsing @PSBoundParameters
        }
    }

    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"
    Write-Debug -Message "Raw Response content:`n $($result.rawcontent)"

    return $result
}