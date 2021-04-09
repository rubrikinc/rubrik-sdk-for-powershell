function ConvertTo-UniversalZuluDateTime {
  <#  
    .SYNOPSIS
    Converts a datetime value to a epoch millisecond timestamp

    .DESCRIPTION
    Some API endpoints require the ISO 8601 notation for datetime stamps for more information about
    this notation head over to Wikipedia: https://en.wikipedia.org/wiki/ISO_8601

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: JaapBrasser

    .EXAMPLE
    ConvertTo-UniversalZuluDateTime -DateTimeValue (Get-Date)

    2021-02-04T21:03:09.000Z
  #>
    [CmdletBinding()]
    param(
        [DateTime]$DateTimeValue
    )

    $return = $DateTimeValue.ToUniversalTime().ToString('o') -replace '\.\d*Z$','.000Z'
    return $return
}