function Get-RubrikDetailedResult($result, $cmdlet) {
    <#
        .SYNOPSIS
        Function to retrieve more detailed results

        .DESCRIPTION
        This function takes a set of results and loops through them performing {id} based queries to retrieve more detailed information

        .PARAMETER result
        Array of objects to retrieve detailed results on

        .PARAMETER cmdlet
        Cmdlet to utilize in order to get detailed results.

        .EXAMPLE
        Get-RubrikDetailedResult -Results $results

        This will take an array of objects ($results) and return more detailed information for each element.
    #>
    Write-Verbose -Message "$(@($result).Count) object(s) detected to query"
    if ($null -ne $result) {
        $returnResult = for ($i = 0; $i -lt @($result).Count; $i++) {
            $Percentage = [int]($i/@($result).count*100)
            Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
            $commandtorun = $cmdlet + " -id " + $result[$i].id
            Invoke-Expression -Command $commandtorun
        }
    }
    else {
        Write-Verbose -Message "Passed results were null, returning null in turn"
        $returnResult = $null
    }

    return $returnResult

}