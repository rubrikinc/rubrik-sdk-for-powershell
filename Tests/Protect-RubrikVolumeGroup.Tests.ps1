Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikVolumeGroup' -Tag 'Public', 'Protect-RubrikVolumeGroup' -Fixture {
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
                'id'                     = 'VolumeGroup:::aaaaaaaa-bbbb-cccc-dddd-2222-333333333333'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
                'hostid'                 = 'Host:::1111-2222'
            }
        }
        Mock -CommandName Get-RubrikHostVolume -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id' = '12345678-1234-abcd-8910-1234567890ab' 
                'hostid' = 'Host:::1111-2222'
            }
        }
        Mock -CommandName Get-RubrikVolumeGroup -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'hostid' = 'Host:::1111-2222'
            }
        }
        It -Name 'Should assign SLA' -Test {
            ( Protect-RubrikVolumeGroup -id 'VolumeGroup:::aaaaaaaa-bbbb-cccc-dddd-2222-333333333333' -SLA 'test-valid_sla_name' ).effectiveSlaDomainName |
                Should -BeExactly 'test-valid_sla_name'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikHostVolume -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }



    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be $null' -Test {
            { Protect-RubrikVolumeGroup -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Protect-RubrikVolumeGroup -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
    }
}