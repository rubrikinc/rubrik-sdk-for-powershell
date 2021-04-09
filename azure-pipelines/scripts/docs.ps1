# Import Module
Import-Module .\Rubrik\Rubrik.psd1 -Force
# $localpath = 'C:\temp\rubrik-sdk-for-powershell'

# Create new markdown and XML help files
Write-Output 'Building new function documentation'

$MarkdownFiles = New-MarkdownHelp -Module Rubrik -OutputFolder "$env:localpath\docs\command-documentation\reference\" -Force | Measure-Object | Select-Object -ExpandProperty Count
Write-Output "Created $MarkdownFiles markdown help files in '$env:localpath\docs\command-documentation\reference\'"

Get-ChildItem $env:localpath\docs\command-documentation\reference\ -Exclude .\README.md |
Where-Object {$_.name -cne $_.name.tolower()} | ForEach-Object {
    Rename-Item -Path "$env:localpath\docs\command-documentation\reference\$($_.Name)" -NewName $_.Name.ToLower()
}

$ExternalHelp = New-ExternalHelp -Path "$env:localpath\docs\command-documentation\reference\" -OutputPath "$env:localpath\Rubrik\en-US\" -Force
Write-Output "Created $($ExternalHelp.Name) external help file in '$env:localpath\Rubrik\en-US\'"

# Custom Generate Summary.md
Write-Output 'Generate custom markdown SUMMARY.md'
$MarkDown = "# Rubrik SDK for PowerShell`n`n"
$MarkDown += "## User Documentation`n`n"

# Documentation folder
Get-ChildItem -LiteralPath "$env:localpath\docs\user-documentation" | ForEach-Object -Process {
    $Reference = switch ($_.BaseName) {
        'Requirements' {'Requirements'}
        'Installation' {'Installation'}
        'Getting_Started' {'Getting Started'}
        'Project_Architecture' {'Project Architecture'}
        'Support' {'Support'}
        'Contribution' {'Contribution'}
        'Licensing' {'Licensing'}
        'FAQ' {'FAQ'}
        default {$_}
    }
    $uri = "$($_.Directory.BaseName)/$($_.Name)"
    $MarkDown += "* [$Reference]($uri)`n"
} -End {
    $MarkDown += "`n----`n`n"
}

$MarkDown += "## Command Documentation`n`n"

# Workflow folder
Get-ChildItem -LiteralPath "$env:localpath\docs\command-documentation\workflow" | ForEach-Object -Begin {
    $MarkDown += "* [Workflow](command-documentation/workflow/readme.md)`n"
} -Process {
    $Reference = switch ($_.BaseName) {
        'flow_audit' {'Flow Audit'}
        default {$_}
    }
    $uri = "command-documentation/$($_.Directory.BaseName)/$($_.Name)"

    if ($_.basename -ne 'readme') {
        $MarkDown += "    * [$Reference]($uri)`n"
    }
} -End {
    # $MarkDown += "`n"
}

# Reference folder
Get-ChildItem -LiteralPath "$env:localpath\docs\command-documentation\reference" | ForEach-Object -Begin {
    $MarkDown += "* [Reference](command-documentation/reference/readme.md)`n"
} -Process {
    $Reference = switch ($_.BaseName) {
        default {
            try {
                $CurrentTry = $_
                ((Get-Content $env:localpath\Rubrik\Public\$_.ps1 -ErrorAction Stop) -match "function $_" -split '\s')[1]
            } catch {
                $CurrentTry
            }
        }
    }
    $uri = "command-documentation/$($_.Directory.BaseName)/$($_.Name)"
    
    if ($_.basename -ne 'readme') {
        $MarkDown += "    * [$Reference]($uri)`n"
    }
}

# Write Markdown to file
Set-Content -Value $MarkDown -Path "$env:localpath\docs\SUMMARY.md"

# End message
Write-Output 'Completed GitBook documentation generation'
