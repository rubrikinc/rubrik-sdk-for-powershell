#Requires -Version 3
function Get-RubrikJob
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on a back-end job

      .DESCRIPTION
      The Get-RubrikJob cmdlet will accept a job ID value and return any information known about that specific job

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikJob -ID 'MOUNT_SNAPSHOT_1234567890:::0'
      Will return details on the job ID MOUNT_SNAPSHOT_1234567890:::0
  #>

  [CmdletBinding()]
  Param(
    # Rubrik job ID value
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$id,
    # Rubrik server IP or FQDN
    [Parameter(Position = 1)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 2)]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('JobGet')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $id

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
        
    try
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
      if ($r.StatusCode -ne $resources.$api.SuccessCode) 
      {
        Write-Warning -Message 'Did not receive successful status code from Rubrik'
        throw $_
      }

      $response = ConvertFrom-Json -InputObject $r.Content
      return $response
    }
    catch
    {
      throw $_
    }


  } # End of process
} # End of function