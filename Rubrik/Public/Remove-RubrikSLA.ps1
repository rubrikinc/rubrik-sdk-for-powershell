#Requires -Version 3
function Remove-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes SLA Domains
            
      .DESCRIPTION
      The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain.
      The SLA Domain must have zero protected objects (VMs, filesets, databases, etc.) in order to be successful.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikSLA.html
            
      .EXAMPLE
      Get-RubrikSLA -SLA 'Gold' | Remove-RubrikSLA
      This will attempt to remove the Gold SLA Domain from Rubrik if there are no objects being protected by the policy
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain id
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function