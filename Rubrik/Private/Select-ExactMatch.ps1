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

        Write-Verbose ('Excluded results not matching -{0} ''{1}'' {2} object(s) filtered, {3} object(s) remaining' -f $Parameter,$Value,($OldCount-@($Result).count),@($Result).count)
    }
}