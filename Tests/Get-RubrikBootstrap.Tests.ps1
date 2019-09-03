Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Get-RubrikBootStrap' -Tag 'Public', 'Get-RubrikBootStrap' -Fixture {
    InModuleScope -ModuleName Rubrik -ScriptBlock {
        Context -Name 'Test script logic' {
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                @{
                    Status = 200
                }
            }

            It -Name 'Should run without error - With all values provided' -Test {
                ( Get-RubrikBootStrap -server 169.254.11.25 -requestid 1 -id me).Status |
                Should -BeExactly 200
            }
            
            It -Name 'Should run without error - Without -id parameter' -Test {
                ( Get-RubrikBootStrap -server 169.254.11.25 -requestid 1).Status |
                Should -BeExactly 200
            }
            
            It -Name 'Should run without error - Without -id & -requestid parameters' -Test {
                ( Get-RubrikBootStrap -server 169.254.11.25).Status |
                Should -BeExactly 200
            }
            
            It -Name 'Should prompt for server ip / name' -Test {
                (Get-Help Get-RubrikBootStrap -Parameter Server).Required |
                Should -BeExactly 'true'
            }
            
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
        }
    }
}