
function Submit-Request {
    <#
        .SYNOPSIS
        Sends data to an endpoint and formats the response

        .DESCRIPTION
        This is function is used by nearly every cmdlet in order to form and send the request off to an API endpoint.
        The results are then formated for further use and returned.
    #>

    [cmdletbinding(supportsshouldprocess=$true)]
    param(
        # The endpoint's URI
        $uri,
        # The header containing authentication details
        $header,
        # The action (method) to perform on the endpoint
        $method = $($resources.Method),
        # Any optional body data being submitted to the endpoint
        $body,
        # Do not throw on an error, Write-Error instead
        [switch] $DoNotThrow
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
                    # In the case of DELETE, there is no content (json body) to parse.
                    $result = if ($null -ne ($WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)) {
                        if ($null -ne $WebResult.Content) {
                            ConvertFrom-Json -InputObject $WebResult.Content
                        } 
                    }
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body
                    if (Test-UnicodeInString -String $WebResult.Content) {
                        $WebResult = [pscustomobject]@{
                            Content = [system.Text.Encoding]::UTF8.GetString($WebResult.RawContentStream.ToArray())
                            StatusCode = $WebResult.StatusCode
                            StatusDescription = $WebResult.StatusDescription
                        }
                    }
                    $result = ExpandPayload -response $WebResult
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
                    $result = ConvertFrom-Json -InputObject (Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body).Content
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body
                    if (Test-UnicodeInString -String $WebResult.Content) {
                        $WebResult = [pscustomobject]@{
                            Content = [system.Text.Encoding]::UTF8.GetString($WebResult.RawContentStream.ToArray())
                            StatusCode = $WebResult.StatusCode
                            StatusDescription = $WebResult.StatusDescription
                        }
                    }
                    $result = ExpandPayload -response $WebResult
                }
            }
        }
        catch {
            switch -Wildcard ($_) {
                'Route not defined.' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    if ($DoNotThrow) {
                        Write-Error -Message $_.Exception
                    } else {
                        throw $_.Exception
                    } 
                }
                'Invalid ManagedId*' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    if ($DoNotThrow) {
                        Write-Error -Message $_.Exception
                    } else {
                        throw $_.Exception
                    } 
                }
                '{"errorType":*' {
                    # Parses the Rubrik generated JSON warning into something a bit more human readable
                    # Fields are: errorType, message, and cause
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    if ($DoNotThrow) {
                        Write-Error -Message $_.Exception
                    } else {
                        throw $_.Exception
                    }
                }
                '{"message":*' {
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    if ($DoNotThrow) {
                        Write-Error -Message $_.Exception
                    } else {
                        throw $_.Exception
                    }
                }
                default {
                    if ($DoNotThrow) {
                        Write-Error -Message $_
                    } else {
                        throw $_
                    }
                }
            }
        }

        return $result 

    }
}
