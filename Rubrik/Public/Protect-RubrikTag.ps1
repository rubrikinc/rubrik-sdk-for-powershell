#Requires -Version 3

function Protect-RubrikTag
{
    <#
            .SYNOPSIS
            Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value
            .DESCRIPTION
            The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values needed to protect workloads.
            .NOTES
            Written by Jason Burrell for community usage
            Twitter: @jasonburrell2
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -vCenter '172.17.48.17'
            This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category
            .EXAMPLE
            Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium' -vCenter '172.17.48.17'
            This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'vSphere Tag value',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Tag,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'vSphere Tag Category value',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Category,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'The Rubrik SLA Domain',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $true,Position = 3,HelpMessage = 'vCenter Server FQDN or IP',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $false,Position = 4,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:rubrikConnection.server
    )

    Process {

        TestRubrikConnection

        ConnectTovCenter -vCenter $vCenter

        Write-Verbose -Message 'Gathering the SLA Domain id'
        try 
        {
            if ($SLA) 
            {
                Write-Verbose -Message 'Using explicit SLA request from input'
                $slaid = Get-RubrikSLA -SLA $SLA
            }
            else 
            {
                Write-Verbose -Message 'No explicit SLA requested; deferring to Tag name'
                $slaid = Get-RubrikSLA -SLA $Tag
            }
        }
        catch
        {
            throw $_
        }

        Write-Verbose -Message 'Gathering the vCenter Server Instance UUID'
        $VCuuid = $global:DefaultVIServer.InstanceUuid

        Write-Verbose -Message "Gathering a list of VMs associated with Category $Category and Tag $Tag"
        try 
        {
            $vmlist = Get-VM -Tag (Get-Tag -Name $Tag -Category $Category) | Get-View
        }
        catch
        {
            throw $_
        }

        Write-Verbose -Message 'Building an array of Rubrik Managed IDs'
        [array]$vmbulk = @()
        foreach ($_ in $vmlist)
        {
            $vmbulk += 'VirtualMachine:::' + $VCuuid + '-' + $($_.moref.value)
            Write-Verbose -Message "Found $($vmbulk.count) records" -Verbose
        }

        Write-Verbose -Message 'Creating the array to mass assign the list of IDs'
        $body = @{
            managedIds = $vmbulk
        }

        Write-Verbose -Message 'Submit the request'
        try 
        {
            if ($PSCmdlet.ShouldProcess("$Tag tagged objects","Assign $($slaid.name) SLA Domain"))
            {
                $uri = 'https://'+$Server+'/slaDomainAssign/'+$slaid.id
                $r = Invoke-WebRequest -Uri $uri -Headers $header -Method Patch -Body (ConvertTo-Json -InputObject $body)
            }
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function
