function Test-RubrikCredential($Username,$Password,[ref]$Credential)
{
  Write-Verbose -Message 'Validate authentication credentials'
  if (($Username -eq $null -or $Password -eq $null) -and $Credential -eq $null)
  {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    $Credential = Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
  }
  else
  {
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
  }
}