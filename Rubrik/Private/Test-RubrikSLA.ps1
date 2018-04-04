Function Test-RubrikSLA($SLA,$Inherit,$DoNotProtect,$Mandatory,$PrimaryClusterID='local')
{
  Write-Verbose -Message 'Determining the SLA Domain id'
  if ($SLA) 
  {
    $slaid = (Get-RubrikSLA -SLA $SLA -PrimaryClusterID $PrimaryClusterID).id
    if ($slaid -eq $null) 
    {
      throw "No SLA Domains were found that match $SLA for $PrimaryClusterID"
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
  if ($Mandatory)
  {
    throw 'No SLA information was entered.'
  }
}
    
