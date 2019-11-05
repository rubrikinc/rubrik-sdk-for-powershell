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

    begin {
        $Value = (Get-Variable -Name $Parameter).Value
    }

    process {
        $OldCount = @($Result).count

        $result = $result | Where-Object {$Value -eq $_.$Parameter}

        Write-Verbose ('Excluded results not matching -{0} ''{1}'' {2} object(s) filtered, {3} object(s) remaining' -f $Parameter,$Value,($OldCount-@($Result).count),@($Result).count)

        return $result
    }
}
