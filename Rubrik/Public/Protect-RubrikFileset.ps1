#Requires -Version 3
function Protect-RubrikFileset
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a fileset
            
      .DESCRIPTION
      The Protect-RubrikFileset cmdlet will update a fileset's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect data.
      Note that this function requires the fileset ID value, not the name of the fileset, since fileset names are not unique across clusters.
      It is suggested that you first use Get-RubrikFileset to narrow down the one or more filesets to protect, and then pipe the results to Protect-RubrikFileset.
      You will be asked to confirm each fileset you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikFileset 'C_Drive' | Protect-RubrikFileset -SLA 'Gold'
      This will assign the Gold SLA Domain to any fileset named "C_Drive"

      .EXAMPLE
      Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Fileset ID
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [ValidateNotNullorEmpty()]
    [String]$FilesetID,
    # The SLA Domain in Rubrik
    [Parameter(Position = 1,ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(Position = 2,ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('FilesetPatch')
  
  }

  Process {
    
    $slaid = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual fileset ID
    $uri = $uri -replace '{id}', $FilesetID
    
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
    
    Write-Verbose -Message 'Build the body'
    $body = @{}
    $body.Add($resources.$api.Body.SLA,$slaid)

    try
    {
      if ($PSCmdlet.ShouldProcess((Get-RubrikFileset -id $FilesetID).name,"Assign SLA Domain $SLA"))
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
