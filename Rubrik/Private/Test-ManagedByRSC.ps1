function Test-ManagedByRSC {   
    <#
        .SYNOPSIS
        Retrieves information around the whether the cluster is managed through RSC

        .DESCRIPTION
        In the event a Rubrik cluster is managed by Rubrik Security Cloud, this function retrieve the RSC instance URI and perform a connection to it

        .EXAMPLE
        Test-ManagedByRSC -ID "clientid" -Secret "client secret"

    #>

    [cmdletbinding()]
    param(
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Id,
        [parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Secret
    )

    
    # Configure parameters to call API to check connection status
    $uri = "https://$($global:rubrikConnection.Server)/api/internal/cluster/me/global_manager"
    
    $headers = $global:rubrikConnection.header
    $method = "GET"

    Write-Verbose -Message "Determining whether Rubrik cluster is managed by RSC with request to $($uri)"
    $response = Invoke-RestMethod -Uri $uri -headers $headers -method $method -SkipCertificateCheck

    # If we are connected to RSC 
    if ($response.isConnected -eq "True") {
        Write-Verbose -Message "Connection to RSC Instance ($($response.url)) detected, checking if address is reachable"
        # Is RSC Reachable (Internet available)
        $rscuri = "$($response.url)/api/client_token"
        if ((Test-Connection $($rscuri.split("/")[2]) -quiet ) -eq $true) {
            Write-Verbose -Message "RSC is reachable, attempting authentication"
            # Let's try and authenticate
            $body = @{
                "client_id" = $id
                "client_secret" = $secret
            }
            try {
                $connection = Invoke-WebRequest -Uri $rscuri -method Post -body $body -skipcertificatecheck | convertfrom-json
            }
            catch {
                Write-Verbose -Message "Problem authenticating to RSC, failing back to CDM Only Mode"
                return $false
            }
            Write-Verbose -Message "Authentication to RSC successful, adding RSC headers and URI to global:rubrikConnection global variable"
            $rscheaders = @{
                "Authorization" = "Bearer $($connection.access_token)"
                "Content-Type" = "application/json"
            }

            # Update Global Variable with RSC connection information
            #$global:rubrikConnection.RSCToken = $connection.access_token
            $global:rubrikConnection.RSCHeaders = $rscheaders
            $global:rubrikConnection.RSCInstance = $($response.url)
            
            #-=MWP=- TODO - Once RSC connection bug is worked out, here is where we would Connect-Rsc
            return $true
        } else {
            Write-Verbose -Message "RSC is not reachable, failing back to CDM only"
            return $false
        }


    } else {
        Write-Verbose -Message "Cluster is not managed by RSC, proceeding in CDM Only mode"
        return $false
    }

    return $response
}