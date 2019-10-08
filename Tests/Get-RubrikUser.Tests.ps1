Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikUser' -Tag 'Public', 'Get-RubrikUser' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikLDAP -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'    =   '1234-1234'
                'name'  =   'LOCAL'
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'username'               = 'jdoe'
                'id'                     = 'User:11111'
                'authDomainId'           = '1234-1234'
                'emailAddress'           = 'jdoe@localhost.local'
            },
            @{ 
                'username'               = 'jsmith'
                'id'                     = 'User:11112'
                'authDomainId'           = '1234-1234'
                'emailAddress'           = 'jsmith@localhost.local'
            },            @{ 
                'username'               = 'dba'
                'id'                     = 'User:111113'
                'authDomainId'           = '1234-5555'
                'emailAddress'           = 'dba@localhost.local'
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikUser).Count |
                Should -BeExactly 3
        } 
        It -Name 'Trigger Get-RubrikLDAP' -Test {
            ( Get-RubrikUser -authDomainId 'local').Count |
                Should -BeExactly 3
        }
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-RubrikLDAP -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikUser -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Username must be System.String' -Test {
            { Get-RubrikUser -UserName } |
                Should -Throw "Missing an argument for parameter 'UserName'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'AuthDomainId must be System.String' -Test {
            { Get-RubrikUser -authDomainId } |
                Should -Throw "Missing an argument for parameter 'authDomainId'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Validate Parameter Set' -Test {
            { Get-RubrikUser -Username 'test' -id 'test' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }

    }
}