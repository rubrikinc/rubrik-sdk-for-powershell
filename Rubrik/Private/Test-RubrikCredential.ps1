function Test-RubrikCredential($Username,[SecureString]$Password,$Credential)
{
  Write-Verbose -Message 'Validate credential'  
  if ($Credential)
  {
    return $Credential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($Username -eq $null -or $Password -eq $null)
  {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
  }
  else
  {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
  }
}
