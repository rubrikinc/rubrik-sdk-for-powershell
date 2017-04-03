#Requires -Version 3
function Set-RubrikBlackout
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets blackout (stops/starts all snaps)

      .DESCRIPTION
      The Set-RubrikBlackout cmdlet will accept a flag of true/false to set cluster blackout

      .NOTES
      Written by Pete Milanese for community usage
      Twitter: @pmilano1
      GitHub: pmilano1

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Set-RubrikBlackout -flag [true/false]
  #>

  [CmdletBinding()]
  Param(
    # Rubrik blackout value
    [Parameter(Position = 0)]
    [ValidateNotNullorEmpty()]
    [ValidateSet('true','false')]
    [String]$Set,
    # Rubrik server IP or FQDN
    [Parameter(Position = 1)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 2)]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
        
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('BlackoutPatch')
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI

    Write-Output $uri

    # Set the method
    $method = $resources.$api.Method


    Write-Verbose -Message 'Defining a body variable for required API params'
    $body = @{}
        
    if ($Set)
    {
      Write-Verbose -Message 'Adding isGlobalBlackoutActive to Body'
      $body.Add($resources.$api.Params.isGlobalBlackoutActive,[System.Convert]::ToBoolean($flag))
    } 

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
