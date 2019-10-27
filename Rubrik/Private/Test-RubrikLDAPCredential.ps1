function Test-RubrikLDAPCredential($BindUserName, [SecureString]$BindUserPassword, $BindCredential) {
  <#
    .SYNOPSIS
    Tests if valid crendential object is available for an LDAP connection

    .DESCRIPTION
    The Test-RubrikLDAPCredential function ensures that a valid PSCredential object is created.
    The function takes either a credential or a username/password combination, and returns a PSCredential object.

    .PARAMETER BindUserName
    The username to use to connect to the LDAP service
    
    .PARAMETER BindUserPassword
    The password for the specified username

    .PARAMETER BindCredential
    The credential object to use to connect to the LDAP service
  #>
  Write-Verbose -Message 'Validate credential'  
  if ($BindCredential) {
    return $BindCredential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($BindUserName -eq $null -or $BindUserPassword -eq $null) {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your LDAP server'
  }
  else {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $BindUserName, $BindUserPassword
  }
}
