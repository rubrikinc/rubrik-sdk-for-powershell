<#
        Helper function to determine if we are connected to a Rubrik cluster by validating the global $RubrikConnection array exists
        The array should contain four items:
        * Header (hashtable) - used for authenticating future RESTful API calls
        * Server (string) - Rubrik cluster IP
        * UserID (string) - GUID of the connected user
        * Token (string) - GUID of the security token
#>
function TestRubrikConnection() 
{
    Write-Verbose -Message 'Validating the Rubrik token exists'
    if (-not $global:RubrikConnection.token) 
    {
        throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
    }
    Write-Verbose -Message 'Found a Rubrik token for authentication'
    $script:Header = $global:RubrikConnection.header
}

