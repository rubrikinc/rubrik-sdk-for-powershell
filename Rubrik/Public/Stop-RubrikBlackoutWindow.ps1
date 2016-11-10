#requires -Version 3
function Stop-RubrikBlackoutWindow
{
    <#  
            .SYNOPSIS
            Stops the Blackout Window (Resumes Protection Activity - part of Rubrik firmware 2.2)
            .DESCRIPTION
            Starts the Blackout Window (Resumes Protection Activity - part of Rubrik firmware 2.2)
            .EXAMPLE
            Stop-RubrikBlackoutWindow
            This will resume the Protection Activity on the Rubrik cluster

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Resumuing Protection Activity on Rubrik Cluster'
        $uri = 'https://'+$Server+"/blackout_window/end"
      
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method post
            $result = (ConvertFrom-Json -InputObject $r.Content)
            return $result
      
    } # End of process
} # End of function
