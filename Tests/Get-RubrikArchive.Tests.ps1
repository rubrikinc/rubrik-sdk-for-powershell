Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikArchive' -Tag 'Public', 'Get-RubrikArchive' -Fixture {
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
            'total' = '3'
            'hasmore' = 'false'
            'data' = @{ 
                'id'                = '3333-2222-3333'
                'name'              = 'S302'
                'rawName'           = 'S302'
                'isActive'          = 'True'
                'bucket'            = 'S302'
                'ownershipStats'    = 'OwnerActive'
                'currentState'      = 'TemporarilyDisconnected'
                'locationType'      = 'S3'   
                },
                @{ 
                'id'                = '2222-2222-3333'
                'name'              = 'S301'
                'rawName'           = 'S301'
                'isActive'          = 'True'
                'bucket'            = 'S301'
                'ownershipStats'    = 'OwnerActive'
                'currentState'      = 'Connected'
                'locationType'      = 'S3'   
                },
                @{ 
                'id'                = '1111-2222-3333'
                'name'              = 'Azure01'
                'rawName'           = 'Azure01'
                'isActive'          = 'True'
                'bucket'            = 'bucket01'
                'ownershipStats'    = 'OwnerActive'
                'currentState'      = 'Connected'
                'locationType'      = 'Azure'   
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikArchive  | Measure-Object ).Count |
                Should -BeExactly 3
        }
        It -Name 'Name filter working' -Test {
            ( Get-RubrikArchive -Name 'Azure01' ).id |
                Should -BeExactly '1111-2222-3333'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikArchive -id } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'ArchiveType ValidateSet' -Test {
            { Get-RubrikArchive -ArchiveType 'non-existant' } |
                Should -Throw "Cannot validate argument on parameter"
        }
        It -Name 'Name cannot be null' -Test {
            { Get-RubrikArchive -Name  } |
                Should -Throw "Missing an argument for parameter 'Name'."
        }

    }
}