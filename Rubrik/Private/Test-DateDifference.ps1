function Test-DateDifference([array]$date,[datetime]$compare)
{
  # The Test-DateDifference function is used to compare a series of dates against a desired date to find the closest matching date/time in the past
  # Thus, a date/time that is one hour older than the request would be valid, but one hour in the future would not be valid
  # $date = An array of ISO 8601 style dates (e.g. YYYY-MM-DDTHH:MM:SSZ)
  # $compare = A single ISO 8601 style date to compare against the $date array
  
  # A simple hashtable is created to compare each date value against one another
  # The value that is closest to 0 (e.g. least distance away from the $compare date) is stored
  # A "placeholder" value of 999999999 is used to find the first value that is greater than 0
  # Otherwise, the date of $null is returned meaning no match
  $datematrix = @{
    date  = $null
    value = 9999999999
  }
 
  foreach ($_ in $date)
  {
    # The $c is just a check variable used to hold the total number of days between the current $date item and the $compare value
    $c = (New-TimeSpan -Start $_ -End $compare).TotalDays
    # Should we find a value that is less than the existing winning value, and it's 0 or greater, store it
    # Note: 0 would be a perfect match (e.g. 0 days different between what we found and what the user wants in $compare)
    # Note: Negative values indicate a future (e.g. supply yesterday for $compare but finding a $date from today)
    if ($c -lt $datematrix.value -and $c -ge 0)
    {
      $datematrix.date = $_
      $datematrix.value = [int]$c
    }
  }
  
  return $datematrix.date
}
