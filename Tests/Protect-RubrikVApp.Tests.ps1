Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikVApp' -Tag 'Public', 'Protect-RubrikVApp' -Fixture {
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
                'id'                     = 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        It -Name 'Should assign SLA' -Test {
            ( Protect-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -SLA 'test-valid_sla_name' ).effectiveSlaDomainName |
                Should -BeExactly 'test-valid_sla_name'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/DoNotProtect' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'UNPROTECTED' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567'
                'effectiveSlaDomainId' = 'UNPROTECTED'
            }
        }
        It -Name 'Should be Unprotected' -Test {
            ( Protect-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -DoNotProtect).effectiveSlaDomainId |
                Should -BeExactly 'UNPROTECTED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter/Inherit' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'id' = 'INHERIT' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567'
                'effectiveSlaDomainId' = 'INHERIT'
            }
        }
        It -Name 'Should be Inherited' -Test {
            ( Protect-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -Inherit).effectiveSlaDomainId |
                Should -BeExactly 'INHERIT'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Protect-RubrikVApp -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Protect-RubrikVApp -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameters SLA and DoNotProtect cannot be simultaneously used' -Test {
            { Protect-RubrikVApp -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -SLA Gold -DoNotProtect} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters SLA and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikVApp -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -SLA Gold -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters DoNotProtect and Inherit cannot be simultaneously used' -Test {
            { Protect-RubrikVApp -Id VcdVapp:::01234567-8910-1abc-d435-0abc1234d567 -DoNotProtect -Inherit} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}