Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikUserRole' -Tag 'Public', 'Set-RubrikUserRole' -Fixture {
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
        Mock -CommandName Update-RubrikUserRole  -ModuleName 'Rubrik' -Mockwith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'readOnlyAdmin'     = '@{basic=}'
                'admin'             = '@{fullAdmin=}'
                'principal'         = 'User:111-222-333'
                'endUser'           = '@{restore="VirtualMachine:111}'           
            }
        }
        It -Name 'User is updated' -Test {
            ( Set-RubrikUserRole -id 'User:11111' -NoAccess).principal |
                Should -BeExactly "User:111-222-333"
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Update-RubrikUserRole -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Set-RubrikUserRole -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String[]' and try again."
        }       
        It -Name 'EndUser must contain Add or Remove' -Test {
            { Set-RubrikUserRole -id 'User:::11111' -EndUser } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Add/Remove only with EndUser' -Test {
            { Set-RubrikUserRole -id 'User:::11111' -Add -NoAccess } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}