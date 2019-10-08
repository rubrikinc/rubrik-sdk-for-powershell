if (6 -ge $PSVersionTable.PSVersion.Major) {
    Write-Output 'Executing PowerShell Core tests'
    Invoke-Pester -Script "$env:LocalPath\Tests\Get-RubrikAPIData.Tests.ps1"
} else {
    Write-Output 'Executing Windows PowerShell tests'
    Invoke-Pester
}