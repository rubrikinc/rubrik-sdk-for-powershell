#requires -Version 3
function Get-RubrikVM
{
    <#  
            .SYNOPSIS
            Retrieves details on one or more virtual machines known to a Rubrik cluster
            .DESCRIPTION
            The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of virtual machines
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikVM -VM 'Server1'
            This will return the ID of the virtual machine named Server1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Filter used to find ACTIVE, RELIC, or ALL virtual machines. Defaults to ALL.')]
        [Alias('archiveStatusFilterOpt')]
        [ValidateNotNullorEmpty()]
        [ValidateSet('ALL', 'ACTIVE', 'RELIC')]
        [String]$Filter = 'ALL',
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'The SLA Domain in Rubrik',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$SLA = '*',
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Gathering VM ID value from Rubrik'
        $uri = 'https://'+$Server+"/vm?archiveStatusFilterOpt=$Filter"

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content) | Where-Object -FilterScript {
                $_.name -like $VM -and $_.effectiveSlaDomainName -like $SLA
            }
            if (!$result) 
            {
                throw "No VM found with the name $VM"
            }
            Write-Verbose -Message "Retrieved ID: $result"
            return $result
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function