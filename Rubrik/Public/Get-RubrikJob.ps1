#Requires -Version 3
function Get-RubrikJob
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves details on a back-end job
            .DESCRIPTION
            The Get-RubrikJob cmdlet will accept a job ID value and return any information known about that specific job
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikJob -ID 'MOUNT_SNAPSHOT_1234567890:::0'
            Will return details on the job ID MOUNT_SNAPSHOT_1234567890:::0
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Rubrik job ID value',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$ID,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:rubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        try 
        {
            Write-Verbose -Message 'Query Rubrik for details on the job ID'
            $uri = 'https://'+$Server+'/job/instance/'+$ID
            $r = Invoke-WebRequest -Uri $uri -Headers $header -Method Get
            $response = ConvertFrom-Json -InputObject $r.Content
            return $response
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function