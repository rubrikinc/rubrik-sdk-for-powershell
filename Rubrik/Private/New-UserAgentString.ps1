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
    param(
        [hashtable] $UserAgentHash
    )

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
            if($psversiontable.os.Length -gt 64) { 
                    $psversiontable.os.Substring(0,64) 
            } else {
                $psversiontable.os.Trim()
            }
        }
        
        $PlatformDetails = "platform--$OS--platform_version--$OSVersion"
        
        $ModuleVersion = try {
            if (-not [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.ScriptBlock.Module.PrivateData.PSData.Prerelease)) {
                $MyInvocation.MyCommand.ScriptBlock.Module.Version.ToString(),
                $MyInvocation.MyCommand.ScriptBlock.Module.PrivateData.PSData.Prerelease.ToString() -join '.'

            } else {
                $MyInvocation.MyCommand.ScriptBlock.Module.Version.ToString()
            }
        } catch {
            
        }
        
        $UserAgent = 'RubrikPowerShellSDK-{0}--{1}--{2}' -f 
            $ModuleVersion,
            $psversiontable.psversion.tostring(),
            $PlatformDetails

        if ($UserAgentHash) {
            $UserAgentHash.keys | ForEach-Object -Begin {
                [string]$StringBuilder = ''
            } -Process {
                $StringBuilder += "--$_--$($UserAgentHash[$_])"
            } -End {
                $UserAgent += $StringBuilder
            }
        }
            
        return $UserAgent
    }
}
