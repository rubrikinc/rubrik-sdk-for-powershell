Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikOrganization' -Tag 'Public', 'New-RubrikOrganization' -Fixture {
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
                'name'                   = 'NewOrg'
                'id'                     = 'Organization:::01234567-8910-1abc-d435-0abc1234d567'
                'isGlobal'               = 'False'
            }
        }
        It -Name 'Organization is created' -Test {
            ( New-RubrikOrganization -Name 'NewOrg' ).name |
                Should -BeExactly 'NewOrg'
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter name cannot be $null' -Test {
            { New-RubrikOrganization -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'name'. The argument is null or empty."
        }
        It -Name 'Parameter name cannot be empty' -Test {
            { New-RubrikOrganization -Name '' } |
                Should -Throw "Cannot validate argument on parameter 'name'. The argument is null or empty."
        }  
    }
}