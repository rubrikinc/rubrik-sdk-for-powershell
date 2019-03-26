function Test-RubrikLDAPCredential($BindUserName,[SecureString]$BindUserPassword,$BindCredential)
{
  Write-Verbose -Message 'Validate credential'  
  if ($BindCredential)
  {
    return $BindCredential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($BindUserName -eq $null -or $BindUserPassword -eq $null)
  {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your LDAP server'
  }
  else
  {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $BindUserName, $BindUserPassword
  }
}
