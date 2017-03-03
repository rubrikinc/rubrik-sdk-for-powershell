Function Test-RubrikSLA($SLA,$Inherit,$DoNotProtect)
{
  Write-Verbose -Message 'Determining the SLA Domain id'
  if ($SLA) 
  {
    $slaid = (Get-RubrikSLA -SLA $SLA).id
    if ($slaid -eq $null) 
    {
      throw "No SLA Domains were found that match $SLA"
    }
    return $slaid
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
    
