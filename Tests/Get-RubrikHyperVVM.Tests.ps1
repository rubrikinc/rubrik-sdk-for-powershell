Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikHyperVVM' -Tag 'Public', 'Get-RubrikHyperVVM' -Fixture {
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
            ( Get-RubrikHyperVVM -SLA 'test-valid_sla_name' ).Name |
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
            ( Get-RubrikHyperVVM -SLAID 'test-valid_sla_id' ).Name |
                Should -BeExactly 'test-vm1'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Get-RubrikHyperVVM -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Get-RubrikHyperVVM -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Get-RubrikHyperVVM -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Get-RubrikHyperVVM -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters Id and Name cannot be simultaneously used' -Test {
            { Get-RubrikHyperVVM -Id VirtualMachine:::1226ff04-6100-454f-905b-5df817b6981a-vm-1025 -Name 'swagsanta' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}