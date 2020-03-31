Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikvCenter' -Tag 'Public', 'Get-RubrikvCenter' -Fixture {
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
                'name'                   = 'vcsa1.domain.com'
                'id'                     = '111111'
                'version'                = '6.7.3'
                'hostname'               = 'vcsa1.domain.com'
            },
            @{
                'name'                   = 'vcsa2.domain.com'
                'id'                     = '111111'
                'version'                = '6.5'
                'hostname'               = 'vcsa2.domain.com'
            }
        }
        It -Name 'Should Return count of 2' -Test {
            ( Get-RubrikvCenter).Count |
                Should -BeExactly 2
        }
        It -Name 'Should Return 6.7.3' -Test {
            (Get-RubrikvCenter -Name 'vcsa1.domain.com').version |
                Should -BeExactly '6.7.3'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}