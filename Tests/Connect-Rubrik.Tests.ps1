# Initial Setup
Import-Module -Name Rubrik -Force

# Variables
if ((Test-Path -Path $PSScriptRoot'\TestVars\test-ip.txt') -eq $true) 
{
    [string]$global:cluster = Get-Content -Path $PSScriptRoot'\TestVars\test-ip.txt'
}
if ((Test-Path -Path $PSScriptRoot'\TestVars\test-cred.xml') -eq $true) 
{
    $global:cred = Import-Clixml -Path $PSScriptRoot'\TestVars\test-cred.xml'
}

Describe -Name 'Connectivity Tests' -Fixture {
    It -name 'Attempting to ping the Rubrik Test Cluster' -test {
        $ping = Test-Connection -ComputerName $global:cluster.Split(':')[0] -Quiet
        $ping | Should be $true
    }

    It -name 'Connects to a Rubrik Test Cluster and gathers a token' -test {
        Connect-Rubrik -Server $global:cluster -Credential $global:cred
        $($global:RubrikConnection.token) | Should Be $true
    }
}