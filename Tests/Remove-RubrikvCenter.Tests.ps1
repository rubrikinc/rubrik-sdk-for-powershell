Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikvCenter' -Tag 'Public', 'Remove-RubrikvCenter' -Fixture {
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

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'                   = '11111-22222-33333'
                'progress'             = '0'
                'startTime'            = '2020-03-30T16:40:20.177'
            }
        }
        It -Name 'Should Return progress of 0' -Test {
            ( Remove-RubrikvCenter -id '11111-22222-33333' ).progress |
                Should -BeExactly 0
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Missing id' -Test {
            { Remove-RubrikvCenter -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }
    }
}