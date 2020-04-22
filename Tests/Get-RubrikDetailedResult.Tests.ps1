Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Get-RubrikDetailedResult' -Tag 'Private', 'Get-RubrikDetailedResult' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0'
    }


    Context -Name "Test Returned Data" -Fixture {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-ReturnFormat -Verifiable -ModuleName 'Rubrik' -MockWith {
            $result
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                'name'                   = 'test-vm1'
                'id'                     = 'vm1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name "Returns proper data - Single result" -Test {
            (Get-RubrikVM -DetailedObject -Name test-vm1).id |
                Should -Be 'vm1'
        }

        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                'name'                   = 'test-vm1'
                'id'                     = 'vm1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
            [pscustomobject]@{
                'name'                   = 'test-vm2'
                'id'                     = 'vm2'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name "Returns proper data - Multiple results" -Test {
            (Get-RubrikVM -DetailedObject -Name test-vm2).name |
                Should -Bein @('test-vm1','test-vm2')
        }

        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Test-ReturnFormat -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }
}