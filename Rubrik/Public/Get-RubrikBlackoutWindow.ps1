#requires -Version 3
function Get-RubrikBlackoutWindow
{
    <#  
            .SYNOPSIS
            Retrieves status from the Rubrik Cluster of "Pause Protection Activity" i.e. Blackout settings (part of Rubrik firmware 2.2)
            .DESCRIPTION
            The Get-RubrikBlackoutWindow gets the current status of the Pause Protection Activity introduced in Rubrik 2.2
            .EXAMPLE
            Get-RubrikBlackoutWindow
            This will return the is BlackoutActive status of true or false

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Gathering Blackout Status value from Rubrik'
        $uri = 'https://'+$Server+"/blackout_window/status"
      
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content)
            return $result
      
    } # End of process
} # End of function
