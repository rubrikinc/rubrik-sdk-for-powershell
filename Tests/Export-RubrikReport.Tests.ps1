Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Export-RubrikReport' -Tag 'Public', 'Export-RubrikReport' -Fixture {
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

    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'data' = @{
                    'url' = 'https://192.168.150.121/report_dir/reportid.csv'
                }
                'hasmore' = 'false'
            }
        }

        Context -Name 'Report Filtering' {
            It -Name 'Should return url for report' -Test {
                ( Export-RubrikReport -id 'reportid').url |
                    Should -BeExactly 'https://192.168.150.121/report_dir/reportid.csv'
            }
        }
        
        Context -Name 'Parameter Validation' {
            It -Name 'Parameter id must be specified' -Test {
                { Export-RubrikReport -id  } |
                    Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
            }
            It -Name 'Parameter id cannot be $null or empty' -Test {
                { Export-RubrikReport -id '' } |
                    Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
            }
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}