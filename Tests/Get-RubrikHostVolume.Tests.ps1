Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikHostVolume' -Tag 'Public', 'Get-RubrikHostVolume' -Fixture {
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
                'total'     = '1'
                'hasMore'   = 'false'
                'data' =  
                @{ 
                    'size'                   = '31558552'
                    'mountPoints'            = 'C:\'
                    'fileSystemType'         = 'NTFS'
                    'id'                     = '1111-2222-3333'
                    'isCurrentlyPresentOnSystem' = 'true'
                },
                @{ 
                    'size'                   = '1233131558552'
                    'mountPoints'            = 'D:\'
                    'fileSystemType'         = 'NTFS'
                    'id'                     = '2222-3333-4444'
                    'isCurrentlyPresentOnSystem' = 'true'
                },
                @{ 
                    'size'                   = '14534531558552'
                    'mountPoints'            = 'E:\'
                    'fileSystemType'         = 'NTFS'
                    'id'                     = '4444-5555-666'
                    'isCurrentlyPresentOnSystem' = 'true'
                }
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikHostVolume -id "Host:11020-29920").Count |
                Should -BeExactly 3
        }
  
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikHostVolume -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        } 
        It -Name 'ID cannot be null or empty' -Test {
            { Get-RubrikHostVolume -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty."
        }       
    }
}