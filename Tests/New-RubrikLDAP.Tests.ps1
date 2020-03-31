Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikLDAP' -Tag 'Public', 'New-RubrikLDAP' -Fixture {
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

    Context -Name 'Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'                = '11111-22222-33333'
                'domainType'        = 'AD'
                'name'              = 'test.com'
                'serviceAccount'    = 'username'
                'dynamicDnsName'    = 'test.com'
            }
        }

        It -Name 'Creates new LDAP Connection' -Test {
            ( New-RubrikLDAP -Name 'test.com' -DynamicDNSName 'test.com' -BindUserName 'asdf' -BindUserPassword (ConvertTo-SecureString -String "password" -AsPlainText -Force)).id |
                Should -BeExactly '11111-22222-33333'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Name is missing' -Test {
            { New-RubrikLDAP -Name  } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'DynamicDNSName is missing' -Test {
            { New-RubrikLDAP -name 'test.com' -DynamicDNSName  } |
                Should Throw "Missing an argument for parameter 'DynamicDnsName'. Specify a parameter of type 'System.String' and try again."
        }
    }
}