$path = (Split-Path -Path $MyInvocation.MyCommand.Path | Split-Path -Parent) + '/Rubrik/Private'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$path/$sut"

Describe "Unblock-SelfSignedCert" { 
    It "Should not throw an error" {
        { Unblock-SelfSignedCert } | 
            Should -Not -Throw
    }
}
