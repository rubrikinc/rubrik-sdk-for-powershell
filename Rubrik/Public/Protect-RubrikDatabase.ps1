#Requires -Version 3
function Protect-RubrikDatabase
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a database
            
      .DESCRIPTION
      The Protect-RubrikDatabase cmdlet will update a database's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the Database ID value, not the name of the database, since database names are not unique across hosts.
      It is suggested that you first use Get-RubrikDatabase to narrow down the one or more database / instance / hosts to protect, and then pipe the results to Protect-RubrikDatabase.
      You will be asked to confirm each database you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikDatabase "DB1" | Protect-RubrikDatabase -SLA 'Gold'
      This will assign the Gold SLA Domain to any database named "DB1"

      .EXAMPLE
      Get-RubrikDatabase "DB1" -Instance "MSSQLSERVER" | Protect-RubrikDatabase -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any database named "DB1" residing on an instance named "MSSQLSERVER" without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Database ID
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [ValidateNotNullorEmpty()]
    [String]$Database,
    # The SLA Domain in Rubrik
    [Parameter(Position = 1,ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(Position = 2,ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # NOT YET IMPLEMENTED
    # Inherits the SLA Domain assignment from a parent object
    #[Parameter(Position = 3,ParameterSetName = 'SLA_Inherit')]
    #[Switch]$Inherit,
    # Rubrik server IP or FQDN
    [Parameter(Position = 4)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 5)]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('MSSQLDBPatch')
  
  }

  Process {
    
    Write-Verbose -Message 'Determining the SLA Domain id'
    if ($SLA) 
    {
      $slaid = (Get-RubrikSLA -SLA $SLA).id
    }
    if ($Inherit) 
    {
      $slaid = 'INHERIT'
    }
    if ($DoNotProtect) 
    {
      $slaid = 'UNPROTECTED'
    }
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual database ID
    $uri = $uri -replace '{id}', $Database
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
    
    Write-Verbose -Message 'Build the body'
    $body = @{}
    $body.Add($resources.$api.Body.SLA,$SnapConsistency)

    try
    {
      if ($PSCmdlet.ShouldProcess($Database,"Assign SLA Domain $slaid"))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik'
          throw $_
        }
        $return = ConvertFrom-Json -InputObject $r.Content
      }
    }
    catch
    {
      throw $_
    }
    
    return $return

  } # End of process
} # End of function
