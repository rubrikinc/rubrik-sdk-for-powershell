#Requires -Version 3
function Get-RubrikTask
{
    <#  
            .SYNOPSIS
            Connects to Rubrik to retrieve either daily or weekly task results
            .DESCRIPTION
            The Get-RubrikTask cmdlet is used to retrieve all of the tasks that have been run by a Rubrik cluster. Use either 'daily' or 'weekly' for ReportType to define the reporting scope.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Report Type (daily or weekly)')]
        [ValidateNotNullorEmpty()]
        [ValidatePattern('daily|weekly')]
        [String]$ReportType,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Export the results to a CSV file')]
        [ValidateNotNullorEmpty()]
        [Switch]$ToCSV,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        # Allow untrusted SSL certs
        Add-Type -TypeDefinition @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy

        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$Server+':443/report/backupJobs/detail'

        Write-Verbose -Message 'Build the body'
        $body = @{
            reportType = $ReportType.ToLower()
        }

        Write-Verbose -Message 'Submit the request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Post -Body (ConvertTo-Json -InputObject $body)
        }
        catch 
        {
            throw $_
        }

        $global:result = (ConvertFrom-Json -InputObject $r.Content)
        Write-Host -Object "$($global:result.count) results have been saved to `$global:result as an array"

        if ($ToCSV)
        {
            Write-Verbose -Message 'Creating CSV'
            $CSVfilename = 'rubrik-tasks-export-'+(Get-Date).Ticks+'.csv'
            try 
            {
                foreach ($record in $global:result)
                {
                    $record | Export-Csv -Append -Path "$Home\Documents\$CSVfilename" -NoTypeInformation -Force
                }
                Write-Host -Object "CSV export written to $Home\Documents\$CSVfilename"
            }
            catch 
            {
                throw $_
            }
        }

    } # End of process
} # End of function