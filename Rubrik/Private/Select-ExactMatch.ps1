function Select-ExactMatch {
    param (
        [parameter(Mandatory)]
        [string] $Parameter,
        [parameter(Mandatory)]
        [string] $Value
    )

    if ($null -ne $PSBoundParameters.Name) {
        $OldCount = @($Result).count

        $result = $result | Where-Object {$Name -eq $_.name}

        Write-Verbose ('Excluded results not matching -Name ''{0}'' {1} object(s) filtered, {2} object(s) remaining' -f $Name,($OldCount-@($Result).count),@($Result).count)
      }
}