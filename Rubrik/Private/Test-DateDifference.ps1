function Test-DateDifference([array]$date, [datetime]$compare, [int]$range) {
  <#
    .SYNOPSIS
    Compares a series of dates against a desired date to find the closest matching date/time

    .DESCRIPTION
    The Rubrik API returns snapshot dates down to the millisecond, but the user may not provide this much detail in their Date argument.
    This function can be used to compare a specified date to the list of snapshot dates in order to find the one that is closest.
    A snapshot date may be in the future by milliseconds, but this is considered valid since that is most likely the intent of the user

    .PARAMETER date
    An array of ISO 8601 style dates (e.g. YYYY-MM-DDTHH:MM:SSZ)
    
    .PARAMETER compare
    A single ISO 8601 style date to compare against the $date array
    
    .PARAMETER range
    defines how many days away from $compare to search for the closest match. Ex: $range = 3 will look within a 3 day period to find a match
  #>
 
  # A simple hashtable is created to compare each date value against one another
  # The value that is closest to 0 (e.g. least distance away from the $compare date) is stored
  # Otherwise, the date of $null is returned meaning no match
  Write-Verbose -Message "Finding closest matching date"
  $datematrix = @{
    date  = $null
    value = $range
  }
 
  foreach ($_ in $date) {
    # The $c is just a check variable used to hold the total number of days between the current $date item and the $compare value
    $c = (New-TimeSpan -Start $_ -End $compare).TotalDays
    # Should we find a value that is less than the existing winning value, store it
    # Note: 0 would be a perfect match (e.g. 0 days different between what we found and what the user wants in $compare)
    # Note: Negative values indicate a future (e.g. supply yesterday for $compare but finding a $date from today)
    # Absolute values are used so negatives are ignored and we find the closest actual match. 
    if ([Math]::Abs($c) -lt $datematrix.value) {
      $datematrix.date = $_
      $datematrix.value = [Math]::Abs($c)
    }

    # If $c = 0, a perfect match has been found
    if ($datematrix.value -eq 0) { break }
  }
  
  If ($null -ne $datematrix.date) {
    Write-Verbose -Message "Using date $($datematrix.date)"
  }
  else {
    Write-Verbose -Message "Could not find matching date within one day of $($compare.ToString())"
  }
  return $datematrix.date
}
