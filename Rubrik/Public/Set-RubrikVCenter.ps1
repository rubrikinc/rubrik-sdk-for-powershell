#Requires -Version 3
function Set-RubrikVCenter
{
    <#  
        .SYNOPSIS
        Connects to Rubrik and modifies an existing vCenter connection
            
        .DESCRIPTION
        The Set-RubrikVCenter cmdlet will modifies an existing vCenter connection on the system. This does require authentication.
            
        .NOTES
        Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
        .LINK
        https://github.com/rubrikinc/PowerShell-Module
            
        .EXAMPLE
        Set-RubrikVCenter -hostname "test-vcenter.domain.com"
        This will return the running cluster settings on the Rubrik cluster.
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
    # vCenter ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # vCenter Hostname (FQDN)
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [string]$Hostname,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
    )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    $id = $Encode = [System.Web.HttpUtility]::UrlEncode($id)
    $Credentials=$(Get-Credential -Message "Type vCenter Credentials.")
    $username = $Credentials.UserName
    $password = $Credentials.GetNetworkCredential().Password

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
    Write-Verbose -Message "Build the body"

    $body = @{
        $resources.Body.hostname = $hostname
        $resources.Body.username = $username
        $resources.Body.password = $password
    }
        
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    #$uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

    } # End of process
} # End of function