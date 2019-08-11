function Select-ExactMatch {
<#
.SYNOPSIS
Helper function, filters API data when infix search is used

.DESCRIPTION
This function only selects exact matches based on 

.EXAMPLE
$result = Select-ExactMatch -Parameter Name -Value $Name -Result $Result

Filters based on the Name parameter and the 
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string] $Parameter,
        [parameter(Mandatory)]
        $Result
    )

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