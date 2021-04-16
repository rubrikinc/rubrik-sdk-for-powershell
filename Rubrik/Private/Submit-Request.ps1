
function Submit-Request {
    <#
        .SYNOPSIS
        Sends data to an endpoint and formats the response

        .DESCRIPTION
        This is function is used by nearly every cmdlet in order to form and send the request off to an API endpoint.
        The results are then formated for further use and returned.

        .PARAMETER uri
        The endpoint's URI
        
        .PARAMETER header
        The header containing authentication details
        
        .PARAMETER method
        The action (method) to perform on the endpoint

        .PARAMETER body
        Any optional body data being submitted to the endpoint
    #>


    [cmdletbinding(supportsshouldprocess=$true)]
    param(
        $uri,
        $header,
        $method = $($resources.Method),
        $body
    )

    # Block to improve readiability of error messages created for issue #653
    switch ($resources.Description) {
        'Delete an SLA Domain from a Rubrik cluster' {$id = "$name $id"}
    }

    if ($PSCmdlet.ShouldProcess($id, $resources.Description)) {
        try {
            Write-Verbose -Message 'Submitting the request'
            if ($resources.method -in ('Delete','Post','Put','Patch')) {
                # Delete operations (and some post) generally have no response body, skip JSON formatting and store the response from Invoke-WebRequest
                if (Test-PowerShellSix) {
                    # Uses the improved ConvertFrom-Json cmdlet as provided in PowerShell 6.1
                    $WebResult = if ($null -ne ($WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)) {
                        ConvertFrom-Json -InputObject $WebResult
                    }
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $result = ExpandPayload -response ($WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                }
                # If $result is null, build a $result object to return to the user. Otherwise, $result will be returned.
                if ($null -eq $result) {   
                    # If if HTTP status code matches our expected result, build a PSObject reflecting success
                    if($WebResult.StatusCode -eq $resources.Success) {
                        $result = [pscustomobject]@{
                            Status = 'Success'
                            HTTPStatusCode = $WebResult.StatusCode
                            HTTPStatusDescription = $WebResult.StatusDescription
                        }
                    } else {
                    # If a different HTTP status is returned, surface that information to the user
                    # This code may never run due to non-200 HTTP codes throwing an HttpResponseException
                        $result = [pscustomobject]@{
                            Status = 'Error'
                            HTTPStatusCode = $WebResult.StatusCode
                            HTTPStatusDescription = $WebResult.StatusDescription
                        }
                    }
                }
            }
            else {
                if (Test-PowerShellSix) {
                    # Uses the improved ConvertFrom-Json cmdlet as provided in PowerShell 6.1
                    $result = ConvertFrom-Json -InputObject (Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $result = ExpandPayload -response (Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                }
            }
        }
        catch {
            switch -Wildcard ($_) {
                'Route not defined.' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    throw $_.Exception 
                }
                'Invalid ManagedId*' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    throw $_.Exception 
                }
                '{"errorType":*' {
                    # Parses the Rubrik generated JSON warning into something a bit more human readable
                    # Fields are: errorType, message, and cause
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    throw $_.Exception
                }
                '{"message":*' {
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    throw $_.Exception
                }
                default {
                    throw $_
                }
            }
        }

        return $result 

    }
}
