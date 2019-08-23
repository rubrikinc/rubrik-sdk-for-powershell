Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikLogShipping' -Tag 'Public', 'Get-RubrikLogShipping' -Fixture {
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
                'id'                    = '11111'
                'location'              = 'test-server01'
                'primaryDatabaseName'   = 'AdventureWorks'
                'secondaryDatabaseName' = 'AdventureWorks_Replica'
            },
            @{ 
                'id'                    = '22222'
                'location'              = 'test-server02'
                'primaryDatabaseName'   = 'AdventureWorks2012'
                'secondaryDatabaseName' = 'AdventureWorks2012_Replica'
            }
        }
        It -Name 'No parameters returns all results' -Test {
            ( Get-RubrikLogShipping).Count |
                Should -BeExactly 2
        }
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikLogShipping -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'PrimaryDatabasename must be System.String' -Test {
            { Get-RubrikLogShipping -PrimaryDatabaseName } |
                Should -Throw "Missing an argument for parameter 'PrimaryDatabaseName'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Status validation must be OK, Broken, Initializing or Stale' -Test {
            { Get-RubrikLogShipping -Status 'NonExistant' } |
                Should -Throw 'Cannot validate argument on parameter ''status''. The argument "NonExistant" does not belong to the set "OK,Broken,Initializing,Stale" specified by the ValidateSet attribute.'
        }
        It -Name 'sort_by validation must be "secondaryDatabaseName", "primaryDatabaseName", "lastAppliedPoint", "location"' -Test {
            { Get-RubrikLogShipping -sort_by  'NonExistant' } |
                Should -Throw 'Cannot validate argument on parameter ''sort_by''. The argument "NonExistant" does not belong to the set "secondaryDatabaseName,primaryDatabaseName,lastAppliedPoint,location" specified by the ValidateSet attribute.'
        }
        It -Name 'sort_order validation must be "asc,desc"' -Test {
            { Get-RubrikLogShipping -sort_order  'NonExistant' } |
                Should -Throw 'Cannot validate argument on parameter ''sort_order''. The argument "NonExistant" does not belong to the set "asc,desc" specified by the ValidateSet attribute.'
        }
    }
}