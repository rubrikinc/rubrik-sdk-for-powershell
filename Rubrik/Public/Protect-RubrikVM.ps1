#Requires -Version 3
function Protect-RubrikVM
{
    <#
            .SYNOPSIS
            Connects to Rubrik and assigns an SLA to a virtual machine
            .DESCRIPTION
            The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values needed to protect workloads.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Protect-RubrikVM -VM 'Server1' -SLA 'Gold'
            This will assign the Gold SLA Domain to a VM named Server1
            .EXAMPLE
            Protect-RubrikVM -VM 'Server1' -Unprotect
            This will remove the SLA Domain assigned to Server1, thus rendering it unprotected
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'The SLA Domain in Rubrik',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Removes the SLA Domain assignment',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$DoNotProtect,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:rubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Matching the SLA input to a valid Rubrik SLA Domain'
        try
        {
            if ($DoNotProtect)
            {
                $slaMatch = @{}
                $slaMatch.id = 'UNPROTECTED'
                $slaMatch.name = 'Unprotected'
            }
            else
            {
                $slaMatch = Get-RubrikSLA -SLA $SLA
            }
            if ($slaMatch -eq $null)
            {
                throw 'Use either -SLA or -DoNotProtect to change the protection status of the VM'
            }
        }
        catch
        {
            throw $_
        }

        Write-Verbose -Message 'Gathering VM ID value from Rubrik'
        $vmid = (Get-RubrikVM -VM $VM).id

        Write-Verbose -Message 'Updating SLA Domain for the requested VM'
        $uri = 'https://'+$Server+'/vm/'+$vmid
        $body = @{
            slaDomainId = $slaMatch.id
        }

        try
        {
            if ($PSCmdlet.ShouldProcess($VM,"Assign $SLA SLA Domain")){
            $r = Invoke-WebRequest -Uri $uri -Headers $header -Body (ConvertTo-Json -InputObject $body) -Method Patch
            if ($r.StatusCode -ne '200')
            {
                throw $r.StatusDescription
            }
            $result = (ConvertFrom-Json -InputObject $r.Content)
            Write-Verbose -Message "$($result.name) set to $($result.slaDomain.name) SLA Domain"
            }
        }
        catch
        {
            throw $_
        }


    } # End of process
} # End of function
