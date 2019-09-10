#Requires -Version 3
function Set-RubrikVCD
{
    <#  
        .SYNOPSIS
        Connects to Rubrik and modifies an existing vCD connection
            
        .DESCRIPTION
        The Set-RubrikVCD cmdlet modifies an existing vCloud Director connection on the system. This does require authentication.
            
        .NOTES
        Written by Matt Elliott for community usage
        Twitter: @NetworkBrouhaha
        GitHub: shamsway
            
        .LINK
        https://github.com/rubrikinc/PowerShell-Module
            
        .EXAMPLE
        Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -SLA "Bronze"
        This will update the vCD cluster settings on the Rubrik cluster and assign the 'Bronze' SLA on the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

        .EXAMPLE
        Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -DoNotProtect
        This will update the vCD cluster settings on the Rubrik cluster and clear the SLA assignment on the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

        .EXAMPLE
        Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -Hostname newserver.company.com
        This will update the vCD cluster settings on the Rubrik cluster to assign a new hostname to the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

        .EXAMPLE
        Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567
        This will update the vCD cluster settings on the Rubrik cluster to update the credentials used to connect to the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
    Param(
    # vCD Instance ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$id,
    # vCD Hostname (FQDN)
    [string]$Hostname,
    # Updates vCD Credentials
    [Switch]$UpdateCreds,
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
    [String]$SLAID = (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect),   
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
    )

    Begin {

        # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
        # If a command needs to be run with each iteration or pipeline input, place it in the Process section
        $id = [System.Web.HttpUtility]::UrlEncode($id)
        if($true -eq $UpdateCreds) {
            $Credentials = $(Get-Credential -Message "Type vCD Credentials.")
            $username = $Credentials.UserName
            $password = $Credentials.GetNetworkCredential().Password
        }

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

        $body = @{}
        
        # Update Credentials
        if($true -eq $UpdateCreds) {
            $body.Add($resources.Body.username, $username)
            $body.Add($resources.Body.password, $password)
        }

        # Update Hostame
        if($true -eq $Hostname) {
            $body.Add($resources.Body.hostname, $hostname)
        }

        # Update SLA
        if($true -eq $SLAID) {
            $body.Add($resources.Body.configuredSlaDomainId, $SLAID)
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