Function Test-RubrikSLA($SLA,$Inherit,$DoNotProtect)
{
  Write-Verbose -Message 'Determining the SLA Domain id'
  if ($SLA) 
  {
    return (Get-RubrikSLA -SLA $SLA).id
  }
  if ($Inherit) 
  {
    return 'INHERIT'
  }
  if ($DoNotProtect) 
  {
    return 'UNPROTECTED'
  }
}
    
