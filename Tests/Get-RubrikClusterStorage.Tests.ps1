Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikClusterStorage' -Tag 'Public', 'Get-RubrikClusterStorage' -Fixture {
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
                'EstimatedRunwayInDays'             = '6629'
                'ArchivalUsageInTb'                 = '2.5'
                'UsedStorageInTb'                   = '2.5'
                'MiscellaneousStorageInGb'          = '0'
                'AvailableStorageInTb'              = '27.6'   
                'ArchivalDataReductionPercent'      = '55.6'
                'FlashCapacityInTb'                 = '1.9'
                'SnapshotStorageInTb'               = '2.7'
                'TotalLocalStorageIngestedInTb'     = '11.9'
                'LiveMountStorageInGb'              = '0'
                'AverageGrowthPerDayInGb'           = '4.2'
                'TotalArchiveStorageIngestedInTb'   = '5.7'
                'DiskCapacityInTb'                  = '46'
                'TotalUsableStorageInTb'            = '30.1'
                'LocalDataReductionPercent'         = '77'
            }
        }
        It -Name 'No parameters returns all results' -Test {
            @( Get-RubrikClusterStorage).Count |
                Should -BeExactly 1
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 7
    }
}