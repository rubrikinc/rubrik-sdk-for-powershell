Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikUser' -Tag 'Public', 'Set-RubrikUser' -Fixture {
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
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'username'               = 'jdoe'
                'id'                     = 'User:11111'
                'authDomainId'           = '1234-1234'
                'emailAddress'           = 'jdoe@localhost.local'
                'firstName'              = 'John'
                'lastName'               = 'Doe'

            }
        }
        It -Name 'User is updated' -Test {
            ( Set-RubrikUser -id 'User:11111' -firstName 'John').firstName |
                Should -BeExactly "John"
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Set-RubrikUser -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Password must be System.SecureString' -Test {
            { Set-RubrikUser -id 'User:::11111' -Password 'newpassword' } |
                Should -Throw "Cannot process argument transformation on parameter 'Password'."
        }
    }
}