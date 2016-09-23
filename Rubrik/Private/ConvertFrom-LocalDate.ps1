<#
Helper function to convert a local format string to datetime
#>
function ConvertFromLocalDate()
{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,HelpMessage = 'Date in your computer local date format',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Date
    )

    try
    {
        $null = $Date -as [datetime]
    }
    catch
    {
        throw 'You did not enter a valid date and time'
    }

    $DateTimeParts = $Date -split ' '
	
	$DateParts = $DateTimeParts[0] -split '/|-|\.'

	$DateFormatParts = (Get-Culture).DateTimeFormat.ShortDatePattern -split '/|-|\.'
    $Month_Index = ($DateFormatParts | Select-String -Pattern 'M').LineNumber - 1
    $Day_Index = ($DateFormatParts | Select-String -Pattern 'd').LineNumber - 1
    $Year_Index = ($DateFormatParts | Select-String -Pattern 'y').LineNumber - 1	
	
	$TimeParts = $DateTimeParts[1..$($DateTimeParts.Count - 1)]
	
	if (@($TimeParts).Count -eq 2)
	{
		$TimeFormatParts = (Get-Culture).DateTimeFormat.ShortTimePattern -split ' '
	
		$TT_Index = ($TimeFormatParts | Select-String -Pattern 't').LineNumber - 1
		$Time_Index = 1 - $TT_Index
		
		$Time = $TimeParts[$Time_Index,$TT_Index] -join ' '
	}
	else
	{
		$Time = $TimeParts
	}
	
	[datetime]$DateTime = [DateTime] $($($DateParts[$Month_Index,$Day_Index,$Year_Index] -join '/') + ' ' + $Time)

    return $DateTime.AddSeconds(59)

}