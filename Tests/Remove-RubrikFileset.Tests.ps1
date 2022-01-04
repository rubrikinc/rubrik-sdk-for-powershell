Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikFileset' -Tag 'Public', 'Remove-RubrikFileset' -Fixture {
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
    #endregion

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                Status = 'Success'
                HTTPStatusCode = 204
            }
        }
        It -Name 'HTTPStatusCode is 204' -Test {
            ( Remove-RubrikFileset -id 'filesetid').HTTPStatusCode  |
                Should -BeExactly 204
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id cannot be $null' -Test {
            { Remove-RubrikFileset -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Parameter id missing' -Test {
            { Remove-RubrikFileset -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
    }

    Context -Name 'Parameter/DoNotProtect/5.2' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            'UNPROTECTED'
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                   = 'Fileset:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
                'effectiveSlaDomainId' = 'UNPROTECTED'
            }
        }
        It -Name 'Should use the 5.2 endpoint' -Test {
            $rubrikconnection.version = '5.2.0'
            $Output = & {
                Protect-RubrikFileset -id 'Fileset::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' -DoNotProtect -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*v2/sla_domain/UNPROTECTED/assign*'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}