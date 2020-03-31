Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikSetting' -Tag 'Public', 'Get-RubrikSetting' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                @{
                    'id'                    = '8b4fe6f6-cc87-4354-a125-b65e23cf8c90'
                    'version'               = '5.1.1'
                    'apiVersion'            = '1'
                    'name'                  = 'RubrikCluster'
                    'acceptedEulaVersion'   = '1.1'
                    'latestEulaVersion'     = '1.1'
                }

        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikSetting).Count |
                Should -BeExactly 1
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID is missing' -Test {
            { Get-RubrikSetting -id } |
                Should -Throw "Missing an argument for parameter 'id'"
        }
    }
}