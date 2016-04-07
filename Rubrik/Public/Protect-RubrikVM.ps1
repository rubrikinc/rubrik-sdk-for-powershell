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

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'The SLA Domain in Rubrik',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Unprotect removes the SLA Domain assignment',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$Unprotect,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        Write-Verbose -Message 'Validating the Rubrik token exists'
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        Write-Verbose -Message 'Matching the SLA input to a valid Rubrik SLA Domain'
        try 
        {
            if ($Unprotect) 
            {
                $SLAmatch.id = 'UNPROTECTED'
                $SLAmatch.name = 'Unprotected'
            }
            else 
            {
                $SLAmatch = Get-RubrikSLA -SLA $SLA
            }
            if ($SLAmatch -eq $null)
            {
                Write-Warning -Message "No matching SLA Domain found with the name `"$SLA`"`nThe following SLA Domains were found:"
                Get-RubrikSLA | Select-Object -Property Name
                break
            }
        }
        catch 
        {
            throw $_
        }

        Write-Verbose -Message 'Gathering VM ID value from Rubrik'
        $uri = 'https://'+$global:RubrikServer+':443/vm?showArchived=false'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content) | Where-Object -FilterScript {
                $_.name -eq $VM
            }
            if (!$result) 
            {
                throw 'No VM found with that name.'
            }
            $vmid = $result.id
            Write-Verbose -Message "Retrieved ID: $vmid"
        }
        catch 
        {
            throw $_
        }

        Write-Verbose -Message 'Updating SLA Domain for the requested VM'
        $uri = 'https://'+$global:RubrikServer+':443/vm/'+$vmid
        $body = @{
            slaDomainId = $SLAmatch.id
        }
        
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Body (ConvertTo-Json -InputObject $body) -Method Patch
            if ($r.StatusCode -ne '200') 
            {
                throw $r.StatusDescription
            }
            $result = (ConvertFrom-Json -InputObject $r.Content)
            Write-Verbose -Message "$($result.name) set to $($result.slaDomain.name) SLA Domain"
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function