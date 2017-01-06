function Verb-RubrikNoun
{
    <#  
            .SYNOPSIS
            !!!Fill Me In!!!
            .DESCRIPTION
            !!!Fill Me In!!!
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Required variable')]
        [ValidateNotNullorEmpty()]
        [String]$RequiredVar,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Optional variable')]
        [ValidateNotNullorEmpty()]
        [Switch]$OptionalVar,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$Server+'/!!!'

        Write-Verbose -Message 'Build the body'
        $body = @{
        !!!
        }

        Write-Verbose -Message 'Submit the request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Post -Body (ConvertTo-Json -InputObject $body)
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function