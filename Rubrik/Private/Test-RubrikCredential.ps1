function Test-RubrikCredential($Username, [SecureString]$Password, $Credential) {
  <#
    .SYNOPSIS
    Tests if valid crendential object is available

    .DESCRIPTION
    The Test-RubrikCredential function ensures that a valid PSCredential object is created.
    The function takes either a credential or a username/password combination, and returns a PSCredential object.

    .PARAMETER username
    The username to use to connect to the Rubrik cluster
    
    .PARAMETER password
    The password for the specified username

    .PARAMETER credential
    The credential object to use to connect to the Rubrik cluster
  #>

  Write-Verbose -Message 'Validate credential'  
  if ($Credential) {
    return $Credential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($Username -eq $null -or $Password -eq $null) {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
  }
  else {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
  }
}
