function Test-Query($object,$param)
{
  if ($object -and $param)
  {
    return "$param=$object"
  }
}
