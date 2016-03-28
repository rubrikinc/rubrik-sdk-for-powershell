# Initial Setup
Import-Module -Name Rubrik -Force
[string]$cluster = Get-Content -Path $PSScriptRoot'\TestVars\test-ip.txt'
$cred = Import-Clixml -Path $PSScriptRoot'\TestVars\test-cred.xml'

Describe "Connectivity Tests" {
    It "Attempting to ping the Rubrik Test Cluster" {
        $ping = Test-Connection -ComputerName $cluster.Split(":")[0] -Quiet
        $ping | Should be $true
    }

    It "Connects to a Rubrik Test Cluster and gathers a token" {
        Connect-Rubrik -Server $cluster -Credential $cred
        $($global:RubrikConnection.token) | Should Be $true
    }
}