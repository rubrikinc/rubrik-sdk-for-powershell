Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/New-UserAgentString' -Tag 'Private', 'New-UserAgentString' -Fixture {
    Context -Name 'Request Succeeds' {
        It -Name 'Should not throw errors' -Test {
            { New-UserAgentString } | 
                Should -Not -Throw
        }
        
        It -Name 'Should return output' -Test {
            ( New-UserAgentString) | 
                Should -Not -BeNullOrEmpty
        }
        
        It -Name 'Should return the PowerShell SDK Name' -Test {
            ((New-UserAgentString) -split '-')[0] |
                Should -BeExactly 'RubrikPowerShellSDK'
        }
        
        It -Name 'Should return correct PowerShell version' -Test {
            ((New-UserAgentString) -split '--')[1] -replace '-' |
                Should -BeExactly $psversiontable.psversion.tostring()
        }
    }
}