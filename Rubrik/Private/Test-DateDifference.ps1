function Test-DateDifference([array]$date,[datetime]$compare)
{
  # The Test-DateDifference function is used to compare a series of dates against a desired date to find the closest matching date/time
  # The Rubrik API returns snapshot dates down to the millisecond, but the user may not provide this much detail in their Date argument
  # A snapshot date may be in the future by milliseconds, but this is considered valid since that is most likely the intent of the user
  # $date = An array of ISO 8601 style dates (e.g. YYYY-MM-DDTHH:MM:SSZ)
  # $compare = A single ISO 8601 style date to compare against the $date array
  
  # A simple hashtable is created to compare each date value against one another
  # The value that is closest to 0 (e.g. least distance away from the $compare date) is stored
  # A "placeholder" value of 1 is used to find the first value within one day of $compare
  # Otherwise, the date of $null is returned meaning no match
  Write-Verbose -Message "Finding closest matching date"
  $datematrix = @{
    date  = $null
    value = 1
  }
 
  foreach ($_ in $date)
  {
    # The $c is just a check variable used to hold the total number of days between the current $date item and the $compare value
    $c = (New-TimeSpan -Start $_ -End $compare).TotalDays
    # Should we find a value that is less than the existing winning value, store it
    # Note: 0 would be a perfect match (e.g. 0 days different between what we found and what the user wants in $compare)
    # Note: Negative values indicate a future (e.g. supply yesterday for $compare but finding a $date from today)
    # Absolute values are used so negatives are ignored and we find the closest actual match. 
    if ([Math]::Abs($c) -lt $datematrix.value)
    {
      $datematrix.date = $_
      $datematrix.value = [Math]::Abs($c)
    }

    # If $c = 0, a perfect match has been found
    if ($datematrix.value -eq 0) { break }
  }
  
  If ($datematrix.date -ne $null) {
    Write-Verbose -Message "Using date $($datematrix.date)"
  }
  else {
    Write-Verbose -Message "Could not find matching date within one day of $($compare.ToString())"
  }
  return $datematrix.date
}
