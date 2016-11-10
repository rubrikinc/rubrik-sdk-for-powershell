#requires -Version 3
function Start-RubrikBlackoutWindow
{
    <#  
            .SYNOPSIS
            Starts the Blackout Window (Pause Protection Activity - part of Rubrik firmware 2.2). This will disable all current and future backup activity
            .DESCRIPTION
            Starts the Blackout Window (Pause Protection Activity - part of Rubrik firmware 2.2). This will disable all current and future backup activity
            .EXAMPLE
            Start-RubrikBlackoutWindow
            This will enable/start the Rubrik Blackout Window (Pause Protection Activity)

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Pausing Protection Activity on Rubrik Cluster'
        $uri = 'https://'+$Server+"/blackout_window/start"
      
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method post
            $result = (ConvertFrom-Json -InputObject $r.Content)
            return $result
      
    } # End of process
} # End of function
