#Requires -Version 3
#Requires -modules VMware.VimAutomation.Core

function Protect-TaggedVM
{
    <#
            .SYNOPSIS
            Connects to Rubrik and assigns an SLA based on a tag value in vSphere
            .DESCRIPTION
            The Protect-TaggedVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values needed to protect workloads.
            .NOTES
            Written by Jason Burrell for community usage
            Twitter: @jasonburrell2
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Protect-TaggedVM -vSphereTag 'Gold' -SLA 'Gold'
            This will assign the Gold SLA Domain to a VM tagged Gold
            Protect-TaggedVM -vSphereTag 'Gold' -Unprotect
            This will remove the SLA Domain assigned to tagged VMs, thus rendering them unprotected
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'vSphere Tag',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Tag,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'The SLA Domain in Rubrik',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Removes the SLA Domain assignment',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$DoNotProtect,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

     Process {

       TestRubrikConnection

        Write-Verbose -Message 'Matching the SLA input to a valid Rubrik SLA Domain'
        try
        {
            if ($SLA -eq $null)
            {
                Write-Warning -Message "No matching SLA Domain found with the name `"$SLA`"`nThe following SLA Domains were found:"
                Get-RubrikSLA | Select-Object -Property Name
                break
            }
            if ($DoNotProtect)
            {
                $SLAmatch = @{}
                $SLAmatch.id = 'UNPROTECTED'
                $SLAmatch.name = 'Unprotected'
            }
            else
            {
                $SLAmatch = Get-RubrikSLA -SLA $SLA 
                $SLAmatch = $SLA
            }
        }
        catch
        {
            throw $_ 
        }

       
        try
        {
        Write-Verbose -Message 'Gathering VMs tagged from vCenter Inventory Service'
       
        $vms = get-vm -tag $Tag -name SE-JBURRELL-WIN
        } 
        catch
        {
            throw $_
        }

        Write-Verbose -Message 'VMs to be updated:'

        Foreach ($VM in $VMs) {
            if ($DoNotProtect){
             Write-host "Unassign $VM from SLA"
            } else {
            Write-host  "Assign $VM to $SLA"
            }
        }

        $Continue = Read-Host -Prompt 'Continue (Y/N)'
        if ($Continue -eq 'Y') {
         Foreach ($VM in $VMs) {
            Write-Host "Assigning Proectiong to $VM"
            
            if ($DoNotProtect) {
                Protect-RubrikVM -VM $VM.Name -DoNotProtect $true
            } else {
                Protect-RubrikVM -VM $VM.Name -SLA $SLA
            }
         }

        } else {
        Write-Verbose "Operation canceled"
        }

    } # End of process
} # End of function
