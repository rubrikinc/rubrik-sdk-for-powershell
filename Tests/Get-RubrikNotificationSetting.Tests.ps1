Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikNotificationSetting' -Tag 'Public', 'Get-RubrikNotificationSetting' -Fixture {
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
                'id'                 = '1111-2222'
                'eventTypes'         = '{Archive,AuthDomain}'
                'snmpAddresses'      = ''
                'shouldSendToSyslog' = 'False'
                'emailAddresses'     = 'testuser@test.com'   
            },
            @{ 
                'id'                 = '1111-3333'
                'eventTypes'         = '{Archive}'
                'snmpAddresses'      = ''
                'shouldSendToSyslog' = 'False'
                'emailAddresses'     = 'testuser2@test.com'   
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikNotificationSetting).Count |
                Should -BeExactly 2
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikNotificationSetting -id } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }       
    }
}