Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikHyperVVM' -Tag 'Public', 'Protect-RubrikHyperVVM' -Fixture {
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
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = '12345678-1234-abcd-8910-1234567890ab' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                     = 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name 'Should assign SLA' -Test {
            ( Protect-RubrikHyperVVM -id 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333' -SLA 'test-valid_sla_name' ).effectiveSlaDomainName |
                Should -BeExactly 'test-valid_sla_name'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Parameter/DoNotProtect' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'UNPROTECTED' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333'
                'effectiveSlaDomainId' = 'UNPROTECTED'
            }
        }
        It -Name 'Should be Unprotected' -Test {
            ( Protect-RubrikHyperVVM -id 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333' -DoNotProtect).effectiveSlaDomainId |
                Should -BeExactly 'UNPROTECTED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Parameter/DoNotProtect/5.2' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            'UNPROTECTED'
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333'
                'effectiveSlaDomainId' = 'UNPROTECTED'
            }
        }
        It -Name 'Should use the 5.2 endpoint' -Test {
            $rubrikconnection.version = '5.2.0'
            $Output = & {
                Protect-RubrikFileset -id 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333' -DoNotProtect -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*v2/sla_domain/UNPROTECTED/assign*'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Parameter/Inherit' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'INHERIT' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333'
                'effectiveSlaDomainId' = 'INHERIT'
            }
        }
        It -Name 'Should be Inherited' -Test {
            ( Protect-RubrikHyperVVM -id 'HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333' -Inherit).effectiveSlaDomainId |
                Should -BeExactly 'INHERIT'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Protect-RubrikHyperVVM -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Protect-RubrikHyperVVM -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters SLA and DoNotProtect cannot be simultaneously used' -Test {
            { Protect-RubrikHyperVVM -Id HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333 -SLA Gold -DoNotProtect} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters SLA and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikHyperVVM -Id HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333 -SLA Gold -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters DoNotProtect and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikHyperVVM -Id HypervVirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffffffff-0000-1111-2222-333333333333 -DoNotProtect -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}