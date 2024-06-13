Install-Module -Name Pester -MaximumVersion 4.2.0 -Force
Remove-Module Pester -ErrorAction SilentlyContinue
Import-Module -Name Pester -MaximumVersion 4.2.0 

$PesterSplat = @{
    PassThru = $true
    OutputFormat = 'NUnitXml'
    OutputFile = "$env:LocalPath\Tests\$env:JobName.xml"
}

if (6 -le $PSVersionTable.PSVersion.Major) {
    Write-Output 'Executing PowerShell Core tests'
 #   $PesterSplat.Script = "$env:LocalPath\Tests\Get-RubrikAPIData.Tests.ps1"
    $TestResult = Invoke-Pester @PesterSplat
} else {
    Write-Output 'Executing Windows PowerShell tests'
    $TestResult = Invoke-Pester @PesterSplat
}

if (($TestResult.FailedCount -gt 0) -or ($null -eq $TestResult)) {
    exit 1
} else {
    "`nWe're happy little campers"
}