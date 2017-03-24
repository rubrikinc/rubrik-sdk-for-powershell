#Requires -Version 3
function Remove-RubrikMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more live mounts
            
      .DESCRIPTION
      The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Remove-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
      This will a live mount with the ID of 11111111-2222-3333-4444-555555555555
            
      .EXAMPLE
      Get-RubrikMount -VM Server1 | Remove-RubrikMount
      This will find and remove any live mount belonging to Server1
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [String]$MountID,
    # Force unmount to deal with situations where host has been moved
    [Parameter(Position = 1)]
    [Switch]$Force,
    # Rubrik server IP or FQDN
    [Parameter(Position = 2)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMMountDelete')
  
  }

  Process {
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual fileset ID
    $uri = $uri -replace '{id}', $MountID

    Write-Verbose -Message 'Build the query parameters'
    $params = @()
    $params += Test-QueryObject -object ([boolean]::Parse($Force)) -location $resources.$api.Params.Force -params $params
    $uri = New-QueryString -params $params -uri $uri -nolimit $false    

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try 
    {
      if ($PSCmdlet.ShouldProcess($MountID,'Removing a Live Mount'))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive a successful status code from Rubrik'
          throw $_
        }
        ConvertFrom-Json -InputObject $r.Content
      }
    }
    catch 
    {
      throw $_
    }

  } # End of process
} # End of function