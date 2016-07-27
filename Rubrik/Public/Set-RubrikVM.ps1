#requires -Version 3
function Set-RubrikVM
{
    <#  
            .SYNOPSIS
            Applies settings on one or more virtual machines known to a Rubrik cluster
            .DESCRIPTION
            The Set-RubrikVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Set-RubrikVM -VM 'Server1' -SnapConsistency AUTO
            This will configure the backup consistency type for Server1 to Automatic (try for application consistency and fail to crash consistency).
            .EXAMPLE
            (Get-RubrikVM -VM * -SLA 'Example').name | Set-RubrikVM -SnapConsistency AUTO
            This will gather the name of all VMs belonging to the SLA Domain named Example and configure the backup consistency type to be crash consistent.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Backup consistency type. Choices are AUTO or CRASH_CONSISTENT')]
        [ValidateSet('AUTO', 'CRASH_CONSISTENT')]
        [String]$SnapConsistency,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Gathering VM ID value from Rubrik'
        $vmid = (Get-RubrikVM -VM $VM).id

        Write-Verbose -Message 'Building the request'
        $uri = 'https://'+$Server+'/vm/'+$vmid

        Write-Verbose -Message 'Validating the consistency type'
        if ($SnapConsistency)
        {
            Write-Verbose -Message 'Translating friendly choice into API value'
            switch ($SnapConsistency)
            {
                AUTO 
                {
                    $SnapVar = ''
                }
                CRASH_CONSISTENT 
                {
                    $SnapVar = 'CRASH_CONSISTENT'
                }
            }
         
            $body = @{
                snapshotConsistencyMandate = $SnapVar
            }
        }

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $header -Body (ConvertTo-Json -InputObject $body) -Method Patch
            $result = ConvertFrom-Json -InputObject $r.Content
            return $result
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function