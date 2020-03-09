Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Resume-RubrikSLA' -Tag 'Public', 'Resume-RubrikSLA' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.1.0'
    }
    #endregion
 
    Context -Name 'ID Parameterset Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id' = '11111a'
                'isPaused' = 'true'
            }
        }

        It -Name 'Request Fulfilled - Validate ID' -Test {
            (Resume-RubrikSLA -id 'ManagedVolume:::11111' ).id |
                Should -BeExactly '11111a'
        }

        It -Name 'Request Fulfilled - Validate isPaused' -Test {
            (Resume-RubrikSLA -id 'ManagedVolume:::11111' ).isPaused |
                Should -BeExactly 'true'
        }

        It -Name 'Parameter ID must be present' -Test {
            { Resume-RubrikSLA -Id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }

    Context -Name 'Name Parameterset Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id' = '11111a'
                'isPaused' = 'true'
            }
        }
        Mock -CommandName Get-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id' = '11111a'
            }
        }

        It -Name 'Request Fulfilled - Validate ID' -Test {
            (Resume-RubrikSLA -Name Test-Jaap580).id |
                Should -BeExactly '11111a'
        }

        It -Name 'Request Fulfilled - Validate isPaused' -Test {
            (Resume-RubrikSLA -Name Test-Jaap580 ).isPaused |
                Should -BeExactly 'true'
        }

        It -Name 'Parameter ID must be present' -Test {
            { Resume-RubrikSLA -Id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}