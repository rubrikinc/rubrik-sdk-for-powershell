# Create new markdown and XML help files
Write-Host "Building new function documentation" -ForegroundColor Yellow
New-MarkdownHelp -Module Rubrik -OutputFolder "$env:LocalPath\docs\reference\" -Force
New-ExternalHelp -Path "$env:LocalPath\docs\reference\" -OutputPath "$env:LocalPath\Rubrik\en-US\" -Force

# Custom Generate Summary.md
$MarkDown = "# Rubrik SDK for PowerShell`n`n"
$MarkDown += "## User Documentation`n`n"

# Documentation folder
Get-ChildItem -LiteralPath "$env:LocalPath\docs\documentation" | ForEach-Object -Process {
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

$MarkDown += "## User Documentation`n`n"

# Workflow folder
Get-ChildItem -LiteralPath "$env:LocalPath\docs\workflow" -Exclude 'readme.md' | ForEach-Object -Begin {
    $MarkDown += "* [Workflow](workflow/readme.md)`n"
} -Process {
    $Reference = switch ($_.BaseName) {
        'flow_audit' {'Flow Audit'}
        default {$_}
    }
    $uri = "$($_.Directory.BaseName)/$($_.Name)"

    $MarkDown += "    * [$Reference]($uri)`n"
} -End {
    $MarkDown += "`n"
}

# Reference folder
Get-ChildItem -LiteralPath "$env:LocalPath\docs\reference" -Exclude 'readme.md' | ForEach-Object -Begin {
    $MarkDown += "* [Reference](workflow/readme.md)`n"
} -Process {
    $Reference = switch ($_.BaseName) {
        default {$_}
    }
    $uri = "$($_.Directory.BaseName)/$($_.Name)"
    
    $MarkDown += "    * [$Reference]($uri)`n"
}

# Write Markdown to file
Set-Content -Value $MarkDown -Path "$env:LocalPath\docs\SUMMARY.md"