Install-Module -Name Pester -Force

$PesterSplat = @{
    PassThru = $true
    OutputFormat = 'NUnitXml'
    OutputFile = "$env:LocalPath\Tests\$env:JobName.xml"
}

if (6 -le $PSVersionTable.PSVersion.Major) {
    Write-Output 'Executing PowerShell Core tests'
    $PesterSplat.Script = "$env:LocalPath\Tests\Get-RubrikAPIData.Tests.ps1"
    $TestResult = Invoke-Pester @PesterSplat
} else {
    Write-Output 'Executing Windows PowerShell tests'
    $TestResult = Invoke-Pester @PesterSplat
}

if ($TestResult.FailedCount -gt 0) {
    exit 1
} else {
    "We're happy little campers"
}