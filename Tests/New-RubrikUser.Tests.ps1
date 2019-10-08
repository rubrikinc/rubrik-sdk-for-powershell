Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikUser' -Tag 'Public', 'New-RubrikUser' -Fixture {
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
            }
        }
        It -Name 'User is created' -Test {
            ( New-RubrikUser -Username 'jdoe' -password (ConvertTo-SecureString -String 'testpass' -AsPlainText -Force)).UserName |
                Should -BeExactly 'jdoe'
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Missing Username' -Test {
            { Get-RubrikUser -username } |
                Should -Throw "Missing an argument for parameter 'Username'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Missing Password' -Test {
            { Get-RubrikUser -password } |
                Should -Throw "A parameter cannot be found that matches parameter name 'password'"
        }    
    }
}