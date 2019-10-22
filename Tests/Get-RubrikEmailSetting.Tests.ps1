Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikEmailSetting' -Tag 'Public', 'Get-RubrikEmailSetting' -Fixture {
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
                'fromEmailId'  = 'rubrikCluster@test.com'
                'smtpUsername' = 'emailuser'
                'smtpHostname' = 'smtp.test.com'
                'smtpPort'     = '25'
                'smtpSecurity' = 'NONE'
                'id'           = '1111-2222-33333'   
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikEmailSetting).Count |
                Should -BeExactly 1
        }

        It -Name 'Email should be rubrikCluster@test.com' -Test {
            @( Get-RubrikEmailSetting).fromEmailId |
                Should -BeExactly 'rubrikCluster@test.com'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
}