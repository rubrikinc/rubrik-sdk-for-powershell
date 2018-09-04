function ConvertTo-EpochMS{
  <#  
      .SYNOPSIS
      Converts a datetime value to a epoch millisecond timestamp

      .DESCRIPTION
      Within Rubrik, recovery points are defined by a epoch millisecond timestamp. This value is
      the number of milliseconds since 1970-01-01. This function will take a datetime value and convert
      it to the epoch millisecond timestamp for use by Rubrik functions.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      ConvertTo-EpochMS -DateTimeValue (Get-Date)
#>
[CmdletBinding()]
param(
    [DateTime]$DateTimeValue
)

    $return = (New-TimeSpan -Start ([datetime]'1970-01-01Z').ToUniversalTime() -End $DateTimeValue.ToUniversalTime()).TotalMilliseconds

    return $return

}