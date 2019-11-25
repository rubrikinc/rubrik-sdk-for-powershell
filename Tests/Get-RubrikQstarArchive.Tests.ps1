Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikQStarArchive' -Tag 'Public', 'Get-RubrikQStarArchive' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0'
    }
    #endregion

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                = '3333-2222-3333'
                'definition'        = @{
                    'name'              = 'QStar01'
                    'objectStoreType'   = 'QStar'
                    'bucket'            = 'QStar01'
                } 
            },
            @{ 
                'id'                = '1111-2222-3333'
                'definition'        = @{
                    'name'              = 'QStar02'
                    'objectStoreType'   = 'QStar'
                    'bucket'            = 'QStar02'
                } 
            },
            @{ 
                'id'                = '2222-2222-3333'
                'definition'        = @{
                    'name'              = 'QStar03'
                    'objectStoreType'   = 'QStar'
                    'bucket'            = 'QStar03'
                } 
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikQStarArchive  | Measure-Object ).Count |
                Should -BeExactly 3
        }
        It -Name 'Name filter working' -Test {
            ( Get-RubrikQStarArchive -Name 'QStar01' ).id |
                Should -BeExactly '3333-2222-3333'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikQStarArchive -id } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Name cannot be null' -Test {
            { Get-RubrikQStarArchive -Name  } |
                Should -Throw "Missing an argument for parameter 'Name'."
        }

    }
}