function New-UserAgentString {
    <#
        .SYNOPSIS
        Helper function, creates a user agent string

        .DESCRIPTION
        Function that generates a user agent string containing the module name, version and OS / platform information

        .NOTES
        Written by Jaap Brasser for community usage
        Twitter: @jaap_brasser
        GitHub: jaapbrasser

        .EXAMPLE
        New-UserAgentString

        Will generate a new user agent string containing the module name, version and OS / platform information
    #>

    process {
        $OS, $OSVersion = if ($psversiontable.PSVersion.Major -lt 6) {
            'Win32NT'
            try {
                Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop | ForEach-Object {
                    ($_.Name -Split '\|')[0], $_.BuildNumber -join ''
                }
            } catch {}
        } else {
            $psversiontable.platform
            $psversiontable.os.trim()
        }
        
        $PlatformDetails = [convert]::ToBase64String("{""platform"": ""$OS"": ""platform_version"": ""$OSVersion""}".ToCharArray())
        
        $UserAgent = 'RubrikPowerShellSDK-{0}--{1}--{2}' -f 
            $MyInvocation.MyCommand.ScriptBlock.Module.Version.ToString(),
            $psversiontable.psversion.tostring(),
            $PlatformDetails
            
        return ($UserAgent -replace '{|}|"')
    }
}
