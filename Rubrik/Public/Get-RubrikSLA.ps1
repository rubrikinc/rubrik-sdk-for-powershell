#Requires -Version 3
function Get-RubrikSLA 
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves details on SLA Domain(s)
            .DESCRIPTION
            The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information on each
            domain will be reported to the console.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikSLA
            Will return all known SLA Domains
            .EXAMPLE
            Get-RubrikSLA -SLA 'Gold'
            Will return details on the SLA Domain named Gold
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Specifies if you want to export your SLA Domain configuration')]
        [Switch]$EnableExport,
        [Parameter(Mandatory = $false, Position = 2,HelpMessage = 'Full path of the file you want your SLA Domains configurations to be exported to. Default is the current user homedir')]
        [ValidateNotNullOrEmpty()]
        [String]$ExportPath,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        Write-Verbose -Message 'Retrieving SLA Domains from Rubrik'
        $uri = 'https://'+$Server+'/slaDomain'

        try 
        {
            $result = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri $uri -Headers $Header -Method Get).Content
			
            if ($EnableExport -and !$ExportPath)
            {
                $ExportPath = $env:userprofile + '\Rubrik_SLADomain_Configuration_' + $(Get-Date -Format o | ForEach-Object -Process {
                        $_ -replace ':', '.'
                }) + '.json'
            }
        }
        catch
        {
            throw $_
        }
		
        Write-Verbose -Message 'Returning the SLA Domain results'
        if ($SLA)
        {
            $SLAresult = $result |
            Where-Object -FilterScript {
                $_.name -match $SLA
            }
        }
        else
        {
            $SLAresult = $result
        }


        if ($EnableExport)
        {
            Write-Verbose -Message "Exporting the SLA Domain results to $ExportPath"
            try
            {
                $SLAresult |
                ConvertTo-Json |
                Out-File $ExportPath
                Write-Warning -Message "Exported the SLA Domain results to $ExportPath"
            }
            catch
            {
                throw $_
            }
        }
        else 
        {
            return $SLAresult
        }
		
    } # End of process
} # End of function