Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' ).FullName ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVM' -Tag 'Public', 'Get-RubrikVM' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion

    Context -Name 'Parameter/SLA' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'test-sla_id' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'test-vm1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            },
            @{ # The server-side filter should not return this record, but this record will validate the response filter logic
                'name'                   = 'test-vm2'
                'effectiveSlaDomainName' = 'test-invalid_sla_name'
            }
        }
        It -Name 'should overwrite $SLAID' -Test {
            ( Get-RubrikVM -SLA 'test-valid_sla_name' -Verbose ).Name |
                Should -BeExactly 'test-vm1'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikSLA -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/SLAID' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'test-vm1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name 'should not overwrite $SLAID' -Test {
            ( Get-RubrikVM -SLAID 'test-valid_sla_id' -Verbose ).Name |
                Should -BeExactly 'test-vm1'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}
