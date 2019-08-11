function Select-ExactMatch {
    param (
        [parameter(Mandatory)]
        [string] $Parameter,
        [parameter(Mandatory)]
        [string] $Value,
        [parameter(Mandatory)]
        $Result
    )

    process {
        $OldCount = @($Result).count

        return $result | Where-Object {$Value -eq $_.$Parameter}

        Write-Verbose ('Excluded results not matching -Name ''{0}'' {1} object(s) filtered, {2} object(s) remaining' -f $Name,($OldCount-@($Result).count),@($Result).count)
    }
}