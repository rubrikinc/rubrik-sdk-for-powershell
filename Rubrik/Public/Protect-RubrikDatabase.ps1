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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Protect-RubrikDatabase
            
      .EXAMPLE
      Get-RubrikDatabase -Name "DB1" | Protect-RubrikDatabase -SLA 'Gold'
      This will assign the Gold SLA Domain to any database named "DB1"

      .EXAMPLE
      Get-RubrikDatabase -Name "DB1" -Instance "MSSQLSERVER" | Protect-RubrikDatabase -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any database named "DB1" residing on an instance named "MSSQLSERVER" without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Database ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID,
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

    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    #endregion One-off

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function